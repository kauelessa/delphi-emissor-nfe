unit Repository.EventoFiscal;

interface

uses
  System.Generics.Collections, Model.EventoFiscal, Infra.Conexao;

type
  IEventoFiscalRepository = interface
    ['{F8B6E5C7-D0C3-43AA-81F6-6C7D8E9FA0B5}']
    procedure Registrar(AEvento: TEventoFiscal);
    function ListarPorNota(ANotaId: Integer): TObjectList<TEventoFiscal>;
    /// Próximo nSeqEvento da CC-e (cada nova carta substitui a anterior).
    function ProximaSequenciaCCe(ANotaId: Integer): Integer;
  end;

  TEventoFiscalRepository = class(TInterfacedObject, IEventoFiscalRepository)
  private
    FConexao: IConexao;
  public
    constructor Create(AConexao: IConexao);
    procedure Registrar(AEvento: TEventoFiscal);
    function ListarPorNota(ANotaId: Integer): TObjectList<TEventoFiscal>;
    function ProximaSequenciaCCe(ANotaId: Integer): Integer;
  end;

implementation

uses
  System.SysUtils, System.Variants, Data.DB, FireDAC.Comp.Client, FireDAC.Stan.Param, Model.Tipos;

constructor TEventoFiscalRepository.Create(AConexao: IConexao);
begin
  inherited Create;
  FConexao := AConexao;
end;

procedure TEventoFiscalRepository.Registrar(AEvento: TEventoFiscal);
var
  LQry: TFDQuery;

  // campos opcionais (inutilização não tem nota, emissão não tem faixa...) vão NULL
  procedure SetInt(const ANome: string; AValor: Integer);
  begin
    LQry.ParamByName(ANome).DataType := ftInteger;
    if AValor > 0 then
      LQry.ParamByName(ANome).AsInteger := AValor
    else
      LQry.ParamByName(ANome).Clear;
  end;

begin
  LQry := FConexao.NovaQuery;
  try
    LQry.SQL.Text :=
      'INSERT INTO NOTA_EVENTO (NOTA_ID, TIPO, DATA_HORA, SEQUENCIA, MODELO, SERIE, ' +
      '  NUMERO_INICIAL, NUMERO_FINAL, CSTAT, MOTIVO, PROTOCOLO, TEXTO, ARQUIVO_XML, SUCESSO) ' +
      'VALUES (:NOTA_ID, :TIPO, :DATA_HORA, :SEQUENCIA, :MODELO, :SERIE, ' +
      '  :NUMERO_INICIAL, :NUMERO_FINAL, :CSTAT, :MOTIVO, :PROTOCOLO, :TEXTO, :ARQUIVO_XML, :SUCESSO) ' +
      'RETURNING ID';
    SetInt('NOTA_ID', AEvento.NotaId);
    LQry.ParamByName('TIPO').AsInteger := Ord(AEvento.Tipo);
    LQry.ParamByName('DATA_HORA').AsDateTime := AEvento.DataHora;
    LQry.ParamByName('SEQUENCIA').AsInteger := AEvento.Sequencia;
    SetInt('MODELO', AEvento.Modelo);
    SetInt('SERIE', AEvento.Serie);
    SetInt('NUMERO_INICIAL', AEvento.NumeroInicial);
    SetInt('NUMERO_FINAL', AEvento.NumeroFinal);
    SetInt('CSTAT', AEvento.CStat);
    LQry.ParamByName('MOTIVO').AsString := Copy(AEvento.Motivo, 1, 255);
    LQry.ParamByName('PROTOCOLO').AsString := AEvento.Protocolo;
    LQry.ParamByName('TEXTO').AsString := Copy(AEvento.Texto, 1, 1000);
    LQry.ParamByName('ARQUIVO_XML').AsString := AEvento.ArquivoXml;
    LQry.ParamByName('SUCESSO').AsBoolean := AEvento.Sucesso;
    LQry.Open;
    AEvento.Id := LQry.FieldByName('ID').AsInteger;
  finally
    LQry.Free;
  end;
end;

function TEventoFiscalRepository.ListarPorNota(ANotaId: Integer): TObjectList<TEventoFiscal>;
var
  LQry: TFDQuery;
  LEvento: TEventoFiscal;
begin
  Result := TObjectList<TEventoFiscal>.Create;
  try
    LQry := FConexao.NovaQuery;
    try
      LQry.Open('SELECT * FROM NOTA_EVENTO WHERE NOTA_ID = :ID ORDER BY DATA_HORA', [ANotaId]);
      while not LQry.Eof do
      begin
        LEvento := TEventoFiscal.Create(TTipoEventoFiscal(LQry.FieldByName('TIPO').AsInteger));
        Result.Add(LEvento);
        LEvento.Id := LQry.FieldByName('ID').AsInteger;
        LEvento.NotaId := LQry.FieldByName('NOTA_ID').AsInteger;
        LEvento.DataHora := LQry.FieldByName('DATA_HORA').AsDateTime;
        LEvento.Sequencia := LQry.FieldByName('SEQUENCIA').AsInteger;
        LEvento.CStat := LQry.FieldByName('CSTAT').AsInteger;
        LEvento.Motivo := LQry.FieldByName('MOTIVO').AsString;
        LEvento.Protocolo := LQry.FieldByName('PROTOCOLO').AsString;
        LEvento.Texto := LQry.FieldByName('TEXTO').AsString;
        LEvento.ArquivoXml := LQry.FieldByName('ARQUIVO_XML').AsString;
        LEvento.Sucesso := LQry.FieldByName('SUCESSO').AsBoolean;
        LQry.Next;
      end;
    finally
      LQry.Free;
    end;
  except
    Result.Free;
    raise;
  end;
end;

function TEventoFiscalRepository.ProximaSequenciaCCe(ANotaId: Integer): Integer;
var
  LMaior: Variant;
begin
  LMaior := FConexao.Connection.ExecSQLScalar(
    'SELECT MAX(SEQUENCIA) FROM NOTA_EVENTO WHERE NOTA_ID = :ID AND TIPO = :TIPO AND SUCESSO = TRUE',
    [ANotaId, Ord(TTipoEventoFiscal.CartaCorrecao)]);
  if VarIsNull(LMaior) then
    Result := 1
  else
    Result := Integer(LMaior) + 1;
end;

end.
