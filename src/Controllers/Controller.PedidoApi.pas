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
    // avisos de faturamento que não chegaram à API; roda calado, só deixa log
    class procedure ReenviarAvisosPendentes;
  end;

implementation

uses
  System.SysUtils, Controller.Fabrica, Infra.Log;

class function TPedidoApiController.Listar(APagina: Integer): TPaginaPedidosApi;
begin
  Result := TFabrica.FaturamentoPedidoService.ListarPedidos(APagina, POR_PAGINA);
end;

class function TPedidoApiController.ProdutosAtivos: TObjectList<TProduto>;
begin
  Result := TFabrica.ProdutoService.Listar('');
end;

class procedure TPedidoApiController.ReenviarAvisosPendentes;
var
  LEnviados: Integer;
begin
  try
    LEnviados := TFabrica.AvisoFaturamento.ReenviarPendentes;
    if LEnviados > 0 then
      Log.Info(Format('%d aviso(s) de faturamento pendente(s) enviado(s) à API', [LEnviados]));
  except
    on E: Exception do
      Log.Erro('Reenvio dos avisos de faturamento falhou: ' + E.Message);
  end;
end;

end.
