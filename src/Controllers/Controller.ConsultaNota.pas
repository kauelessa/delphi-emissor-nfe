unit Controller.ConsultaNota;

interface

uses
  System.Generics.Collections, Model.Tipos, Model.Nota, Service.Nota;

type
  TConsultaNotaController = class
  private
    FService: INotaService;
  public
    constructor Create;
    function Listar(const AFiltro: TFiltroNota): TObjectList<TNota>;
    function Cancelar(ANotaId: Integer; const AJustificativa: string): TResultadoOperacao;
    function CartaCorrecao(ANotaId: Integer; const ACorrecao: string): TResultadoOperacao;
    function TransmitirContingencia(ANotaId: Integer): TResultadoOperacao;
    function Inutilizar(AModelo: TModeloNota; ASerie, ANumeroInicial, ANumeroFinal: Integer;
      const AJustificativa: string): TResultadoOperacao;
    procedure Imprimir(ANotaId: Integer);
    function GerarPdf(ANotaId: Integer): string;
    function EnviarEmail(ANotaId: Integer; const AEmail: string): TResultadoOperacao;
    function EmailDoCliente(ANotaId: Integer): string;
    function ExportarXml(ANotaId: Integer; const APasta: string): string;
  end;

implementation

uses
  Model.Cliente, Controller.Fabrica;

constructor TConsultaNotaController.Create;
begin
  inherited;
  FService := TFabrica.NotaService;
end;

function TConsultaNotaController.Listar(const AFiltro: TFiltroNota): TObjectList<TNota>;
begin
  Result := FService.Listar(AFiltro);
end;

function TConsultaNotaController.Cancelar(ANotaId: Integer; const AJustificativa: string): TResultadoOperacao;
begin
  Result := FService.Cancelar(ANotaId, AJustificativa);
end;

function TConsultaNotaController.CartaCorrecao(ANotaId: Integer; const ACorrecao: string): TResultadoOperacao;
begin
  Result := FService.CartaCorrecao(ANotaId, ACorrecao);
end;

function TConsultaNotaController.TransmitirContingencia(ANotaId: Integer): TResultadoOperacao;
begin
  Result := FService.TransmitirContingencia(ANotaId);
end;

function TConsultaNotaController.Inutilizar(AModelo: TModeloNota; ASerie, ANumeroInicial,
  ANumeroFinal: Integer; const AJustificativa: string): TResultadoOperacao;
begin
  Result := FService.Inutilizar(AModelo, ASerie, ANumeroInicial, ANumeroFinal, AJustificativa);
end;

procedure TConsultaNotaController.Imprimir(ANotaId: Integer);
begin
  FService.Imprimir(ANotaId);
end;

function TConsultaNotaController.GerarPdf(ANotaId: Integer): string;
begin
  Result := FService.GerarPdf(ANotaId);
end;

function TConsultaNotaController.EnviarEmail(ANotaId: Integer; const AEmail: string): TResultadoOperacao;
begin
  Result := FService.EnviarEmail(ANotaId, AEmail);
end;

function TConsultaNotaController.EmailDoCliente(ANotaId: Integer): string;
var
  LNota: TNota;
  LCliente: TCliente;
begin
  Result := '';
  LNota := FService.Obter(ANotaId);
  try
    if (LNota = nil) or (LNota.ClienteId = 0) then
      Exit;
    LCliente := TFabrica.ClienteService.Obter(LNota.ClienteId);
    try
      if LCliente <> nil then
        Result := LCliente.Email;
    finally
      LCliente.Free;
    end;
  finally
    LNota.Free;
  end;
end;

function TConsultaNotaController.ExportarXml(ANotaId: Integer; const APasta: string): string;
begin
  Result := FService.ExportarXml(ANotaId, APasta);
end;

end.
