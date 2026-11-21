unit Infra.Migracao;

{
  Migrações do banco, aplicadas na abertura do sistema.

  Os scripts .sql da pasta configurada (database\ por padrão) rodam em ordem
  de nome de arquivo, por isso a numeração 001_, 002_... Cada script aplicado
  é gravado na tabela SCHEMA_VERSAO e nunca roda de novo: mudança no banco vai
  sempre num script NOVO, com o próximo número.

  Scripts com "_seed_" no nome trazem dados de exemplo (emitente fictício,
  produtos, cliente de teste) e só rodam com [Migracao] ExecutarSeeds=1. Seed
  pulado não é registrado, então se a opção for ligada depois ele roda na
  próxima abertura.

  Cada script roda numa transação explícita. Como os scripts terminam com
  COMMIT próprio (para rodarem também no isql), uma falha no meio pode deixar
  parte dele aplicada; nesse caso o sistema não abre, mostra o erro e o script
  não é marcado como aplicado.
}

interface

uses
  System.SysUtils, System.Classes, FireDAC.Comp.Client, Infra.Config;

type
  TMigrador = class
  private
    FConexao: TFDConnection;
    FPasta: string;
    FExecutarSeeds: Boolean;
    FUltimoErro: string;
    procedure ScriptErro(ASender, AInitiator: TObject; var AException: Exception);
    procedure GarantirTabelaControle;
    procedure CarregarAplicados(AAplicados: TStrings);
    procedure AplicarScript(const AArquivo: string);
  public
    const MARCADOR_SEED = '_seed_';

    constructor Create(AConexao: TFDConnection; const AConfig: TConfigMigracao);
    /// Aplica os scripts pendentes e devolve os nomes dos que rodaram.
    function Aplicar: TArray<string>;

    // regras de seleção separadas do banco, para os testes
    class function EhSeed(const AArquivo: string): Boolean; static;
    /// AAplicados deve ser uma lista sem diferenciar maiúsculas.
    class function ScriptsPendentes(const AArquivos: TArray<string>; AAplicados: TStrings;
      AExecutarSeeds: Boolean): TArray<string>; static;
  end;

implementation

uses
  System.IOUtils, System.StrUtils, System.Generics.Defaults, System.Generics.Collections,
  FireDAC.Stan.Intf, FireDAC.Comp.Script,
  FireDAC.Comp.ScriptCommands; // registra COMMIT, SET TERM etc. no TFDScript

{ TMigrador }

constructor TMigrador.Create(AConexao: TFDConnection; const AConfig: TConfigMigracao);
begin
  inherited Create;
  FConexao := AConexao;
  FPasta := AConfig.Pasta;
  FExecutarSeeds := AConfig.ExecutarSeeds;
end;

class function TMigrador.EhSeed(const AArquivo: string): Boolean;
begin
  Result := ContainsText(ExtractFileName(AArquivo), MARCADOR_SEED);
end;

class function TMigrador.ScriptsPendentes(const AArquivos: TArray<string>; AAplicados: TStrings;
  AExecutarSeeds: Boolean): TArray<string>;
var
  LOrdenados: TArray<string>;
  LPendentes: TList<string>;
  LArquivo: string;
begin
  LOrdenados := Copy(AArquivos);
  TArray.Sort<string>(LOrdenados, TComparer<string>.Construct(
    function(const AEsquerda, ADireita: string): Integer
    begin
      Result := CompareText(ExtractFileName(AEsquerda), ExtractFileName(ADireita));
    end));

  LPendentes := TList<string>.Create;
  try
    for LArquivo in LOrdenados do
    begin
      if AAplicados.IndexOf(ExtractFileName(LArquivo)) >= 0 then
        Continue;
      if EhSeed(LArquivo) and not AExecutarSeeds then
        Continue;
      LPendentes.Add(LArquivo);
    end;
    Result := LPendentes.ToArray;
  finally
    LPendentes.Free;
  end;
end;

function TMigrador.Aplicar: TArray<string>;
var
  LAplicados: TStringList;
  LArquivo: string;
begin
  if not TDirectory.Exists(FPasta) then
    raise Exception.CreateFmt('Pasta de scripts não encontrada: %s', [FPasta]);

  LAplicados := TStringList.Create;
  try
    LAplicados.CaseSensitive := False;
    GarantirTabelaControle;
    CarregarAplicados(LAplicados);

    Result := ScriptsPendentes(TDirectory.GetFiles(FPasta, '*.sql'), LAplicados, FExecutarSeeds);

    for LArquivo in Result do
    begin
      // transação explícita é obrigatória: em autocommit o COMMIT do script
      // chega ao Firebird sem transação aberta ("invalid transaction handle")
      FConexao.StartTransaction;
      try
        AplicarScript(LArquivo);
        // se o script não terminar com COMMIT, o registro entra junto com ele
        if not FConexao.InTransaction then
          FConexao.StartTransaction;
        FConexao.ExecSQL('INSERT INTO SCHEMA_VERSAO (SCRIPT) VALUES (:SCRIPT)',
          [ExtractFileName(LArquivo)]);
        FConexao.Commit;
      except
        if FConexao.InTransaction then
          FConexao.Rollback;
        raise;
      end;
    end;
  finally
    LAplicados.Free;
  end;
end;

procedure TMigrador.GarantirTabelaControle;
begin
  if FConexao.ExecSQLScalar(
    'SELECT COUNT(*) FROM RDB$RELATIONS WHERE RDB$RELATION_NAME = ''SCHEMA_VERSAO''') > 0 then
    Exit;

  FConexao.ExecSQL(
    'CREATE TABLE SCHEMA_VERSAO (' +
    '  SCRIPT      VARCHAR(100) NOT NULL,' +
    '  APLICADO_EM TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,' +
    '  CONSTRAINT PK_SCHEMA_VERSAO PRIMARY KEY (SCRIPT)' +
    ')');
end;

procedure TMigrador.CarregarAplicados(AAplicados: TStrings);
var
  LQry: TFDQuery;
begin
  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := FConexao;
    LQry.Open('SELECT SCRIPT FROM SCHEMA_VERSAO');
    while not LQry.Eof do
    begin
      AAplicados.Add(LQry.Fields[0].AsString.Trim);
      LQry.Next;
    end;
  finally
    LQry.Free;
  end;
end;

procedure TMigrador.ScriptErro(ASender, AInitiator: TObject; var AException: Exception);
begin
  FUltimoErro := AException.Message;
end;

procedure TMigrador.AplicarScript(const AArquivo: string);
var
  LScript: TFDScript;
  LSucesso: Boolean;
begin
  FUltimoErro := '';
  LScript := TFDScript.Create(nil);
  try
    LScript.Connection := FConexao;
    LScript.ScriptOptions.FileEncoding := ecUTF8;
    LScript.ScriptOptions.BreakOnError := True;
    LScript.OnError := ScriptErro;
    LScript.SQLScriptFileName := AArquivo;

    try
      LSucesso := LScript.ExecuteAll;
    except
      on E: Exception do
        raise Exception.CreateFmt('Falha ao aplicar %s: %s', [ExtractFileName(AArquivo), E.Message]);
    end;

    if not LSucesso then
      raise Exception.CreateFmt('Falha ao aplicar %s: %s', [ExtractFileName(AArquivo), FUltimoErro]);
  finally
    LScript.Free;
  end;
end;

end.
