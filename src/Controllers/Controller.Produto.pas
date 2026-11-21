unit Controller.Produto;

interface

uses
  System.Generics.Collections, Model.Produto, Service.Produto;

type
  TProdutoController = class
  private
    FService: IProdutoService;
  public
    constructor Create;
    function Listar(const AFiltro: string = ''): TObjectList<TProduto>;
    function Obter(AId: Integer): TProduto;
    procedure Salvar(AProduto: TProduto);
    procedure Inativar(AId: Integer);
  end;

implementation

uses
  Controller.Fabrica;

constructor TProdutoController.Create;
begin
  inherited;
  FService := TFabrica.ProdutoService;
end;

function TProdutoController.Listar(const AFiltro: string): TObjectList<TProduto>;
begin
  Result := FService.Listar(AFiltro);
end;

function TProdutoController.Obter(AId: Integer): TProduto;
begin
  Result := FService.Obter(AId);
end;

procedure TProdutoController.Salvar(AProduto: TProduto);
begin
  FService.Salvar(AProduto);
end;

procedure TProdutoController.Inativar(AId: Integer);
begin
  FService.Inativar(AId);
end;

end.
