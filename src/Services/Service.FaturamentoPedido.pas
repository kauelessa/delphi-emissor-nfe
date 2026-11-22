unit Service.FaturamentoPedido;

{
  Faturamento de pedidos da delphi-horse-api: transforma um pedido da API numa NF-e
  preenchida no emissor.

  A API só conhece a parte comercial (cliente, produto, quantidade, preço). Os dados
  fiscais vêm sempre dos cadastros do emissor:
  - o cliente é localizado pelo CPF/CNPJ; se não existir, a tela cadastra (callback);
  - cada produto da API é ligado a um produto do emissor (PRODUTO_VINCULO_API); sem
    vínculo, ou com o produto vinculado inativo, a tela pergunta qual usar (callback).

  Tudo é resolvido ANTES de mexer na nota: se o usuário cancelar qualquer pergunta,
  a nota e os vínculos ficam como estavam.
}

interface

uses
  System.SysUtils, Model.Nota, Model.PedidoApi, Infra.ApiPedidos, Infra.Log, Service.Nota,
  Repository.Nota, Repository.Cliente, Repository.Produto, Repository.VinculoProduto;

type
  /// Cadastra no emissor o cliente vindo da API. Devolve o id criado; 0 = cancelou.
  TCadastrarCliente = reference to function(ACliente: TClienteApi): Integer;
  /// Escolhe o produto do emissor para um item da API. Devolve o id; 0 = cancelou.
  TEscolherProduto = reference to function(AItem: TItemPedidoApi): Integer;

  IFaturamentoPedidoService = interface
    ['{A4C6E8F0-2B1D-4F3A-8C5E-7D9B1F3A5C26}']
    function ListarPedidos(APagina, ALimite: Integer): TPaginaPedidosApi;
    /// False = o usuário cancelou um dos passos; a nota fica intacta.
    function Importar(ANota: TNota; APedidoId: Integer; const ACadastrarCliente: TCadastrarCliente;
      const AEscolherProduto: TEscolherProduto): Boolean;
  end;

  TFaturamentoPedidoService = class(TInterfacedObject, IFaturamentoPedidoService)
  private
    FApi: IPedidoApi;
    FNotaService: INotaService;
    FNotaRepo: INotaRepository;
    FClienteRepo: IClienteRepository;
    FProdutoRepo: IProdutoRepository;
    FVinculoRepo: IVinculoProdutoRepository;
    FLog: ILog;
    function ProdutoAtivo(AProdutoId: Integer): Boolean;
    function ResolverCliente(APedido: TPedidoApi; const ACadastrar: TCadastrarCliente): Integer;
  public
    constructor Create(AApi: IPedidoApi; ANotaService: INotaService; ANotaRepo: INotaRepository;
      AClienteRepo: IClienteRepository; AProdutoRepo: IProdutoRepository;
      AVinculoRepo: IVinculoProdutoRepository; ALog: ILog);
    function ListarPedidos(APagina, ALimite: Integer): TPaginaPedidosApi;
    function Importar(ANota: TNota; APedidoId: Integer; const ACadastrarCliente: TCadastrarCliente;
      const AEscolherProduto: TEscolherProduto): Boolean;
  end;

implementation

uses
  System.Generics.Collections, Model.Tipos, Model.Cliente, Model.Produto, Infra.Documento;

constructor TFaturamentoPedidoService.Create(AApi: IPedidoApi; ANotaService: INotaService;
  ANotaRepo: INotaRepository; AClienteRepo: IClienteRepository; AProdutoRepo: IProdutoRepository;
  AVinculoRepo: IVinculoProdutoRepository; ALog: ILog);
begin
  inherited Create;
  FApi := AApi;
  FNotaService := ANotaService;
  FNotaRepo := ANotaRepo;
  FClienteRepo := AClienteRepo;
  FProdutoRepo := AProdutoRepo;
  FVinculoRepo := AVinculoRepo;
  FLog := ALog;
end;

function TFaturamentoPedidoService.ListarPedidos(APagina, ALimite: Integer): TPaginaPedidosApi;
var
  LPedido: TPedidoApi;
  LNota: TNota;
begin
  Result := FApi.Listar(APagina, ALimite);
  try
    for LPedido in Result.Pedidos do
    begin
      LNota := FNotaRepo.ObterFaturadaDoPedido(LPedido.Id);
      if LNota <> nil then
      try
        LPedido.NotaNumero := LNota.Numero;
      finally
        LNota.Free;
      end;
    end;
  except
    Result.Free;
    raise;
  end;
end;

function TFaturamentoPedidoService.ProdutoAtivo(AProdutoId: Integer): Boolean;
var
  LProduto: TProduto;
begin
  LProduto := FProdutoRepo.Obter(AProdutoId);
  try
    Result := (LProduto <> nil) and LProduto.Ativo;
  finally
    LProduto.Free;
  end;
end;

function TFaturamentoPedidoService.ResolverCliente(APedido: TPedidoApi;
  const ACadastrar: TCadastrarCliente): Integer;
var
  LClienteApi: TClienteApi;
  LCliente: TCliente;
begin
  // o pedido só traz id e nome do cliente; o documento vem do cadastro da API
  LClienteApi := FApi.ObterCliente(APedido.ClienteId);
  try
    LCliente := FClienteRepo.ObterPorDocumento(SoNumeros(LClienteApi.Documento));
    if LCliente <> nil then
    try
      Exit(LCliente.Id);
    finally
      LCliente.Free;
    end;
    Result := ACadastrar(LClienteApi);
  finally
    LClienteApi.Free;
  end;
end;

function TFaturamentoPedidoService.Importar(ANota: TNota; APedidoId: Integer;
  const ACadastrarCliente: TCadastrarCliente; const AEscolherProduto: TEscolherProduto): Boolean;
var
  LPedido: TPedidoApi;
  LFaturada: TNota;
  LClienteId, I: Integer;
  LProdutos: TArray<Integer>;
  LNovosVinculos: TList<TPair<Integer, Integer>>;
  LVinculo: TPair<Integer, Integer>;
begin
  if (ANota.Modelo <> TModeloNota.NFe) or not ANota.Editavel or (ANota.Itens.Count > 0) then
    raise EValidacao.Create('Importe o pedido numa NF-e nova, sem itens.');

  LPedido := FApi.Obter(APedidoId);
  LNovosVinculos := TList<TPair<Integer, Integer>>.Create;
  try
    if LPedido.Status = TStatusPedidoApi.Cancelado then
      raise EValidacao.Create('Pedido cancelado na API não pode ser faturado.');
    if LPedido.Itens.Count = 0 then
      raise EValidacao.CreateFmt('Pedido %d não tem itens.', [LPedido.Id]);

    LFaturada := FNotaRepo.ObterFaturadaDoPedido(LPedido.Id);
    if LFaturada <> nil then
    try
      raise EValidacao.CreateFmt('Pedido %d já faturado na NF-e %d.', [LPedido.Id, LFaturada.Numero]);
    finally
      LFaturada.Free;
    end;

    // 1) resolve cliente e produtos sem tocar na nota
    LClienteId := ResolverCliente(LPedido, ACadastrarCliente);
    if LClienteId = 0 then
      Exit(False);

    SetLength(LProdutos, LPedido.Itens.Count);
    for I := 0 to LPedido.Itens.Count - 1 do
    begin
      LProdutos[I] := FVinculoRepo.ProdutoDoEmissor(LPedido.Itens[I].ProdutoId);
      if (LProdutos[I] = 0) or not ProdutoAtivo(LProdutos[I]) then
      begin
        LProdutos[I] := AEscolherProduto(LPedido.Itens[I]);
        if LProdutos[I] = 0 then
          Exit(False);
        LNovosVinculos.Add(TPair<Integer, Integer>.Create(LPedido.Itens[I].ProdutoId, LProdutos[I]));
      end;
    end;

    // 2) grava os vínculos novos e preenche a nota
    for LVinculo in LNovosVinculos do
    begin
      FVinculoRepo.Gravar(LVinculo.Key, LVinculo.Value);
      FLog.Info(Format('Produto %d da API vinculado ao produto %d do emissor', [LVinculo.Key, LVinculo.Value]));
    end;

    try
      for I := 0 to LPedido.Itens.Count - 1 do
        FNotaService.AdicionarItemComPreco(ANota, LProdutos[I], LPedido.Itens[I].Quantidade,
          LPedido.Itens[I].PrecoUnitario);
    except
      // não deixa a nota pela metade se um item falhar
      while ANota.Itens.Count > 0 do
        FNotaService.RemoverItem(ANota, ANota.Itens.Count - 1);
      raise;
    end;
    ANota.ClienteId := LClienteId;
    ANota.PedidoApiId := LPedido.Id;
    ANota.Observacao := Format('Pedido nº %d (delphi-horse-api)', [LPedido.Id]);

    FLog.Info(Format('Pedido %d importado na nota (%d itens, total %m)',
      [LPedido.Id, ANota.Itens.Count, ANota.ValorTotal]));
    Result := True;
  finally
    LNovosVinculos.Free;
    LPedido.Free;
  end;
end;

end.
