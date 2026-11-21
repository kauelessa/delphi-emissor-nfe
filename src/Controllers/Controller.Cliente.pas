unit Controller.Cliente;

interface

uses
  System.Generics.Collections, Model.Cliente, Service.Cliente;

type
  TClienteController = class
  private
    FService: IClienteService;
  public
    constructor Create;
    function Listar(const AFiltro: string = ''): TObjectList<TCliente>;
    function Obter(AId: Integer): TCliente;
    procedure Salvar(ACliente: TCliente);
    procedure Inativar(AId: Integer);
  end;

implementation

uses
  Controller.Fabrica;

constructor TClienteController.Create;
begin
  inherited;
  FService := TFabrica.ClienteService;
end;

function TClienteController.Listar(const AFiltro: string): TObjectList<TCliente>;
begin
  Result := FService.Listar(AFiltro);
end;

function TClienteController.Obter(AId: Integer): TCliente;
begin
  Result := FService.Obter(AId);
end;

procedure TClienteController.Salvar(ACliente: TCliente);
begin
  FService.Salvar(ACliente);
end;

procedure TClienteController.Inativar(AId: Integer);
begin
  FService.Inativar(AId);
end;

end.
