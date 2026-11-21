unit Controller.Emitente;

interface

uses
  Model.Emitente, Service.Emitente;

type
  TEmitenteController = class
  private
    FService: IEmitenteService;
  public
    constructor Create;
    function Obter: TEmitente;
    procedure Salvar(AEmitente: TEmitente);
    function DescricaoCertificado: string;
  end;

implementation

uses
  System.SysUtils, Controller.Fabrica, Infra.Config;

constructor TEmitenteController.Create;
begin
  inherited;
  FService := TFabrica.EmitenteService;
end;

function TEmitenteController.Obter: TEmitente;
begin
  Result := FService.Obter;
end;

procedure TEmitenteController.Salvar(AEmitente: TEmitente);
begin
  FService.Salvar(AEmitente);
end;

function TEmitenteController.DescricaoCertificado: string;
begin
  if Config.NFe.Certificado = '' then
    Result := 'Nenhum certificado configurado no config.ini'
  else if not FileExists(Config.NFe.Certificado) then
    Result := 'Arquivo não encontrado: ' + Config.NFe.Certificado
  else
    Result := Config.NFe.Certificado;
end;

end.
