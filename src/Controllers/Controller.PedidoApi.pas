unit Controller.PedidoApi;

interface

uses
  System.Generics.Collections, Model.PedidoApi, Model.Produto;

type
  TPedidoApiController = class
  public const
    POR_PAGINA = 20;
  public
    class function Listar(APagina: Integer): TPaginaPedidosApi;
    class function ProdutosAtivos: TObjectList<TProduto>;
  end;

implementation

uses
  Controller.Fabrica;

class function TPedidoApiController.Listar(APagina: Integer): TPaginaPedidosApi;
begin
  Result := TFabrica.FaturamentoPedidoService.ListarPedidos(APagina, POR_PAGINA);
end;

class function TPedidoApiController.ProdutosAtivos: TObjectList<TProduto>;
begin
  Result := TFabrica.ProdutoService.Listar('');
end;

end.
