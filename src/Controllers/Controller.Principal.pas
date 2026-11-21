unit Controller.Principal;

interface

uses
  Model.Tipos;

type
  TPrincipalController = class
  public
    class function PrepararBanco(out AErro: string): Boolean;
    function ConfigEncontrado: Boolean;
    function Homologacao: Boolean;
    function DescricaoAmbiente: string;
    function DescricaoEmitente: string;
    function StatusServico(AModelo: TModeloNota): TResultadoOperacao;
    procedure RegistrarErro(const AMensagem: string);
  end;

implementation

uses
  System.SysUtils, Model.Emitente, Controller.Fabrica, Infra.Config, Infra.Log,
  Infra.Documento, Infra.Conexao, Infra.Migracao;

class function TPrincipalController.PrepararBanco(out AErro: string): Boolean;
var
  LMigrador: TMigrador;
  LScript: string;
begin
  Result := True;
  AErro := '';
  // sem config.ini a tela principal já avisa; não adianta tentar o banco
  if not Config.ArquivoExiste or not Config.Migracao.Executar then
    Exit;

  try
    if Config.Migracao.CriarBanco then
      Conexao.CriarBancoSeNaoExistir;

    LMigrador := TMigrador.Create(Conexao.Connection, Config.Migracao);
    try
      for LScript in LMigrador.Aplicar do
        Log.Info('Migração aplicada: ' + ExtractFileName(LScript));
    finally
      LMigrador.Free;
    end;
  except
    on E: Exception do
    begin
      Log.Erro('Falha ao preparar o banco: ' + E.Message);
      AErro := E.Message;
      Result := False;
    end;
  end;
end;

function TPrincipalController.ConfigEncontrado: Boolean;
begin
  Result := Config.ArquivoExiste;
end;

function TPrincipalController.Homologacao: Boolean;
begin
  Result := Config.NFe.Ambiente = TAmbienteFiscal.Homologacao;
end;

function TPrincipalController.DescricaoAmbiente: string;
begin
  if Homologacao then
    Result := 'Ambiente: HOMOLOGAÇÃO (sem valor fiscal)'
  else
    Result := 'Ambiente: PRODUÇÃO';
  Result := Result + ' - UF ' + Config.NFe.UF;
end;

function TPrincipalController.DescricaoEmitente: string;
var
  LEmitente: TEmitente;
begin
  // sem config.ini nem tenta conectar, só ia gerar erro de login no Firebird
  if not ConfigEncontrado then
    Exit('Banco de dados não configurado');
  try
    LEmitente := TFabrica.EmitenteService.Obter;
    try
      if LEmitente.Id = 0 then
        Result := 'Emitente não cadastrado'
      else
        Result := LEmitente.RazaoSocial + ' - ' + FormatarCpfCnpj(LEmitente.CNPJ);
    finally
      LEmitente.Free;
    end;
  except
    on E: Exception do
    begin
      Log.Erro('Falha ao conectar no banco: ' + E.Message);
      Result := 'Banco de dados não conectado (veja o config.ini)';
    end;
  end;
end;

function TPrincipalController.StatusServico(AModelo: TModeloNota): TResultadoOperacao;
begin
  Result := TFabrica.NotaService.StatusServico(AModelo);
end;

procedure TPrincipalController.RegistrarErro(const AMensagem: string);
begin
  Log.Erro(AMensagem);
end;

end.
