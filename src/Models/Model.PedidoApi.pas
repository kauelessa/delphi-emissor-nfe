unit Model.PedidoApi;

// Pedido e cliente como vêm da delphi-horse-api. Não são gravados no banco do emissor.

interface

uses
  System.Generics.Collections;

type
  {$SCOPEDENUMS ON}
  TStatusPedidoApi = (Aberto, Cancelado);
  {$SCOPEDENUMS OFF}

  TItemPedidoApi = class
  public
    ProdutoId: Integer;
    Descricao: string;
    Quantidade: Integer;
    PrecoUnitario: Currency;
    ValorTotal: Currency;
  end;

  TPedidoApi = class
  private
    FItens: TObjectList<TItemPedidoApi>;
  public
    Id: Integer;
    ClienteId: Integer;
    ClienteNome: string;
    Data: TDateTime;
    Status: TStatusPedidoApi;
    ValorTotal: Currency;
    // número da NF-e do emissor que faturou o pedido (0 = não faturado); preenchido pelo service
    NotaNumero: Integer;
    constructor Create;
    destructor Destroy; override;
    property Itens: TObjectList<TItemPedidoApi> read FItens;
  end;

  TClienteApi = class
  public
    Id: Integer;
    Nome: string;
    Documento: string;
    Email: string;
    Telefone: string;
  end;

  TPaginaPedidosApi = class
  private
    FPedidos: TObjectList<TPedidoApi>;
  public
    Pagina: Integer;
    Total: Integer;
    constructor Create;
    destructor Destroy; override;
    function TotalPaginas(ALimite: Integer): Integer;
    property Pedidos: TObjectList<TPedidoApi> read FPedidos;
  end;

implementation

constructor TPedidoApi.Create;
begin
  inherited;
  FItens := TObjectList<TItemPedidoApi>.Create;
end;

destructor TPedidoApi.Destroy;
begin
  FItens.Free;
  inherited;
end;

constructor TPaginaPedidosApi.Create;
begin
  inherited;
  FPedidos := TObjectList<TPedidoApi>.Create;
end;

destructor TPaginaPedidosApi.Destroy;
begin
  FPedidos.Free;
  inherited;
end;

function TPaginaPedidosApi.TotalPaginas(ALimite: Integer): Integer;
begin
  if (ALimite <= 0) or (Total <= 0) then
    Exit(1);
  Result := (Total + ALimite - 1) div ALimite;
end;

end.
