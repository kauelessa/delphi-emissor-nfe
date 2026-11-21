unit Controller.FormaPagamento;

interface

uses
  System.Generics.Collections, Model.FormaPagamento, Service.FormaPagamento;

type
  TFormaPagamentoController = class
  private
    FService: IFormaPagamentoService;
  public
    constructor Create;
    function Listar(AApenasAtivas: Boolean = False): TObjectList<TFormaPagamento>;
    function Obter(AId: Integer): TFormaPagamento;
    procedure Salvar(AForma: TFormaPagamento);
  end;

implementation

uses
  Controller.Fabrica;

constructor TFormaPagamentoController.Create;
begin
  inherited;
  FService := TFabrica.FormaPagamentoService;
end;

function TFormaPagamentoController.Listar(AApenasAtivas: Boolean): TObjectList<TFormaPagamento>;
begin
  Result := FService.Listar(AApenasAtivas);
end;

function TFormaPagamentoController.Obter(AId: Integer): TFormaPagamento;
begin
  Result := FService.Obter(AId);
end;

procedure TFormaPagamentoController.Salvar(AForma: TFormaPagamento);
begin
  FService.Salvar(AForma);
end;

end.
