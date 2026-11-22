unit Test.FaturamentoPedido;

interface

uses
  System.SysUtils, System.Generics.Collections, DUnitX.TestFramework, Model.Tipos, Model.Nota,
  Model.PedidoApi, Infra.ApiPedidos, Service.Nota, Service.FaturamentoPedido, Test.Fakes;

type
  TItemFake = record
    ProdutoId, Quantidade: Integer;
    Preco: Currency;
  end;

  // pedido 12 da API, com o cliente e os itens que o teste configurar
  TPedidoApiFake = class(TInterfacedObject, IPedidoApi)
  public
    Status: TStatusPedidoApi;
    ClienteDocumento: string;
    Itens: TList<TItemFake>;
    constructor Create;
    destructor Destroy; override;
    procedure AdicionarItem(AProdutoId, AQuantidade: Integer; APreco: Currency);
    function Listar(APagina, ALimite: Integer): TPaginaPedidosApi;
    function Obter(AId: Integer): TPedidoApi;
    function ObterCliente(AId: Integer): TClienteApi;
    procedure Faturar(APedidoId, ANumero, ASerie: Integer; const AChave: string; AAutorizadaEm: TDateTime);
    procedure RemoverFaturamento(APedidoId: Integer);
  end;

  [TestFixture]
  TTestFaturamentoPedido = class
  private
    FApi: TPedidoApiFake;
    FNotaRepo: TFakeNotaRepository;
    FClienteRepo: TFakeClienteRepository;
    FProdutoRepo: TFakeProdutoRepository;
    FVinculos: TFakeVinculoRepository;
    FLog: TFakeLog;
    FNotaService: INotaService;
    FService: IFaturamentoPedidoService;
    FNota: TNota;
    FRefs: array of IInterface;
    // callbacks: quantas vezes foram chamados, o que receberam e o que devolvem
    FCadastros: Integer;
    FClienteRecebido: string;
    FIdClienteNovo: Integer;
    FEscolhas: Integer;
    FRespostasEscolha: TQueue<Integer>;
    function Importar: Boolean;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    [Test]
    procedure PedidoCancelado_Recusa;
    [Test]
    procedure PedidoComNotaAutorizada_Recusa;
    [Test]
    procedure PedidoComNotaRejeitada_Importa;
    [Test]
    procedure NotaComItens_Recusa;
    [Test]
    procedure NotaNFCe_Recusa;
    [Test]
    procedure ClienteEncontradoPeloDocumento_NaoChamaCallback;
    [Test]
    procedure ClienteAusente_ChamaCallbackComDadosDaApi;
    [Test]
    procedure ClienteAusente_CallbackCancela_NotaIntacta;
    [Test]
    procedure VinculoExistente_UsaSemPerguntar;
    [Test]
    procedure VinculoAusente_PerguntaEGrava;
    [Test]
    procedure VinculoParaProdutoInativo_PerguntaDeNovo;
    [Test]
    procedure CancelaNoSegundoItem_NotaIntacta;
    [Test]
    procedure MesmoProdutoEmOutroPedido_NaoPerguntaDeNovo;
    [Test]
    procedure PrecoEQuantidadeVemDoPedido;
    [Test]
    procedure DemaisDadosFiscaisVemDoEmissor;
    [Test]
    procedure GravaPedidoEObservacao;
    [Test]
    procedure ListarPedidos_PreencheNumeroDaNota;
  end;

implementation

{ TPedidoApiFake }

constructor TPedidoApiFake.Create;
begin
  inherited;
  Itens := TList<TItemFake>.Create;
  ClienteDocumento := '529.982.247-25';
end;

destructor TPedidoApiFake.Destroy;
begin
  Itens.Free;
  inherited;
end;

procedure TPedidoApiFake.AdicionarItem(AProdutoId, AQuantidade: Integer; APreco: Currency);
var
  LItem: TItemFake;
begin
  LItem.ProdutoId := AProdutoId;
  LItem.Quantidade := AQuantidade;
  LItem.Preco := APreco;
  Itens.Add(LItem);
end;

function TPedidoApiFake.Listar(APagina, ALimite: Integer): TPaginaPedidosApi;
begin
  Result := TPaginaPedidosApi.Create;
  Result.Pagina := APagina;
  Result.Total := 2;
  Result.Pedidos.Add(Obter(12));
  Result.Pedidos.Add(Obter(13));
end;

function TPedidoApiFake.Obter(AId: Integer): TPedidoApi;
var
  LFake: TItemFake;
  LItem: TItemPedidoApi;
begin
  Result := TPedidoApi.Create;
  Result.Id := AId;
  Result.ClienteId := 3;
  Result.ClienteNome := 'Maria Souza';
  Result.Status := Status;
  for LFake in Itens do
  begin
    LItem := TItemPedidoApi.Create;
    LItem.ProdutoId := LFake.ProdutoId;
    LItem.Descricao := 'Produto da API ' + LFake.ProdutoId.ToString;
    LItem.Quantidade := LFake.Quantidade;
    LItem.PrecoUnitario := LFake.Preco;
    LItem.ValorTotal := LFake.Preco * LFake.Quantidade;
    Result.Itens.Add(LItem);
  end;
end;

procedure TPedidoApiFake.Faturar(APedidoId, ANumero, ASerie: Integer; const AChave: string;
  AAutorizadaEm: TDateTime);
begin
end;

procedure TPedidoApiFake.RemoverFaturamento(APedidoId: Integer);
begin
end;

function TPedidoApiFake.ObterCliente(AId: Integer): TClienteApi;
begin
  Result := TClienteApi.Create;
  Result.Id := AId;
  Result.Nome := 'Maria Souza';
  Result.Documento := ClienteDocumento;
  Result.Email := 'maria@exemplo.com';
  Result.Telefone := '11999990000';
end;

{ TTestFaturamentoPedido }

procedure TTestFaturamentoPedido.Setup;
begin
  FApi := TPedidoApiFake.Create;
  FNotaRepo := TFakeNotaRepository.Create;
  FClienteRepo := TFakeClienteRepository.Create;
  FProdutoRepo := TFakeProdutoRepository.Create;
  FVinculos := TFakeVinculoRepository.Create;
  FLog := TFakeLog.Create;
  FRefs := [FApi as IInterface, FNotaRepo as IInterface, FClienteRepo as IInterface,
    FProdutoRepo as IInterface, FVinculos as IInterface, FLog as IInterface];

  FNotaService := TNotaService.Create(FNotaRepo, TFakeEmitenteRepository.Create, FClienteRepo,
    FProdutoRepo, TFakeFormaPagamentoRepository.Create, TFakeEventoRepository.Create,
    TFakeEmissor.Create, TFakeArquivoXml.Create, FLog);
  FService := TFaturamentoPedidoService.Create(FApi, FNotaService, FNotaRepo, FClienteRepo,
    FProdutoRepo, FVinculos, FLog);

  // padrão: pedido 12 com o produto 7 da API (vinculado ao 1 do emissor), 2 x 279,90
  FApi.AdicionarItem(7, 2, 279.90);
  FVinculos.Gravar(7, 1);

  FNota := FNotaService.NovaNota(TModeloNota.NFe);
  FCadastros := 0;
  FClienteRecebido := '';
  FIdClienteNovo := 1;
  FEscolhas := 0;
  FRespostasEscolha := TQueue<Integer>.Create;
end;

procedure TTestFaturamentoPedido.TearDown;
begin
  FNota.Free;
  FRespostasEscolha.Free;
  FService := nil;
  FNotaService := nil;
  FRefs := nil;
end;

function TTestFaturamentoPedido.Importar: Boolean;
begin
  Result := FService.Importar(FNota, 12,
    function(ACliente: TClienteApi): Integer
    begin
      Inc(FCadastros);
      FClienteRecebido := ACliente.Nome + '|' + ACliente.Documento + '|' + ACliente.Email;
      Result := FIdClienteNovo;
    end,
    function(AItem: TItemPedidoApi): Integer
    begin
      Inc(FEscolhas);
      if FRespostasEscolha.Count > 0 then
        Result := FRespostasEscolha.Dequeue
      else
        Result := 0;
    end);
end;

procedure TTestFaturamentoPedido.PedidoCancelado_Recusa;
begin
  FApi.Status := TStatusPedidoApi.Cancelado;
  Assert.WillRaiseWithMessage(
    procedure
    begin
      Importar;
    end, EValidacao, 'Pedido cancelado na API não pode ser faturado.');
  Assert.AreEqual(0, FNota.Itens.Count);
end;

procedure TTestFaturamentoPedido.PedidoComNotaAutorizada_Recusa;
begin
  FNotaRepo.PedidoFaturado := 12;
  FNotaRepo.NumeroNotaFaturada := 345;
  Assert.WillRaiseWithMessage(
    procedure
    begin
      Importar;
    end, EValidacao, 'Pedido 12 já faturado na NF-e 345.');
end;

procedure TTestFaturamentoPedido.PedidoComNotaRejeitada_Importa;
begin
  // nota rejeitada não aparece como faturada no repositório (só autorizada/contingência)
  FNotaRepo.PedidoFaturado := 0;
  Assert.IsTrue(Importar);
  Assert.AreEqual(1, FNota.Itens.Count);
end;

procedure TTestFaturamentoPedido.NotaComItens_Recusa;
begin
  FNotaService.AdicionarItem(FNota, 2, 1);
  Assert.WillRaiseWithMessage(
    procedure
    begin
      Importar;
    end, EValidacao, 'Importe o pedido numa NF-e nova, sem itens.');
end;

procedure TTestFaturamentoPedido.NotaNFCe_Recusa;
begin
  FNota.Modelo := TModeloNota.NFCe;
  Assert.WillRaiseWithMessage(
    procedure
    begin
      Importar;
    end, EValidacao, 'Importe o pedido numa NF-e nova, sem itens.');
end;

procedure TTestFaturamentoPedido.ClienteEncontradoPeloDocumento_NaoChamaCallback;
begin
  Assert.IsTrue(Importar);
  Assert.AreEqual(0, FCadastros);
  Assert.AreEqual(1, FNota.ClienteId);
end;

procedure TTestFaturamentoPedido.ClienteAusente_ChamaCallbackComDadosDaApi;
begin
  FApi.ClienteDocumento := '11.222.333/0001-81';
  FIdClienteNovo := 1;
  Assert.IsTrue(Importar);
  Assert.AreEqual(1, FCadastros);
  Assert.AreEqual('Maria Souza|11.222.333/0001-81|maria@exemplo.com', FClienteRecebido);
  Assert.AreEqual(1, FNota.ClienteId);
end;

procedure TTestFaturamentoPedido.ClienteAusente_CallbackCancela_NotaIntacta;
begin
  FApi.ClienteDocumento := '11.222.333/0001-81';
  FIdClienteNovo := 0;
  Assert.IsFalse(Importar);
  Assert.AreEqual(0, FNota.ClienteId);
  Assert.AreEqual(0, FNota.Itens.Count);
  Assert.AreEqual(0, FNota.PedidoApiId);
  Assert.AreEqual('', FNota.Observacao);
end;

procedure TTestFaturamentoPedido.VinculoExistente_UsaSemPerguntar;
begin
  Assert.IsTrue(Importar);
  Assert.AreEqual(0, FEscolhas);
  Assert.AreEqual(1, FNota.Itens[0].ProdutoId);
end;

procedure TTestFaturamentoPedido.VinculoAusente_PerguntaEGrava;
begin
  FApi.AdicionarItem(8, 1, 50);
  FRespostasEscolha.Enqueue(2);
  Assert.IsTrue(Importar);
  Assert.AreEqual(1, FEscolhas);
  Assert.AreEqual(2, FVinculos.ProdutoDoEmissor(8));
  Assert.AreEqual(2, FNota.Itens[1].ProdutoId);
end;

procedure TTestFaturamentoPedido.VinculoParaProdutoInativo_PerguntaDeNovo;
begin
  FProdutoRepo.InativoId := 1;
  FRespostasEscolha.Enqueue(2);
  Assert.IsTrue(Importar);
  Assert.AreEqual(1, FEscolhas);
  Assert.AreEqual(2, FVinculos.ProdutoDoEmissor(7));
  Assert.AreEqual(2, FNota.Itens[0].ProdutoId);
end;

procedure TTestFaturamentoPedido.CancelaNoSegundoItem_NotaIntacta;
begin
  FApi.AdicionarItem(8, 1, 50);
  // fila vazia: a escolha do produto 8 devolve 0 (cancelou)
  Assert.IsFalse(Importar);
  Assert.AreEqual(1, FEscolhas);
  Assert.AreEqual(0, FNota.Itens.Count);
  Assert.AreEqual(0, FNota.ClienteId);
  Assert.AreEqual(0, FNota.PedidoApiId);
  Assert.AreEqual(0, FVinculos.ProdutoDoEmissor(8));
end;

procedure TTestFaturamentoPedido.MesmoProdutoEmOutroPedido_NaoPerguntaDeNovo;
begin
  FApi.Itens.Clear;
  FApi.AdicionarItem(8, 1, 50);
  FRespostasEscolha.Enqueue(2);
  Assert.IsTrue(Importar);

  FNota.Free;
  FNota := FNotaService.NovaNota(TModeloNota.NFe);
  Assert.IsTrue(Importar);
  Assert.AreEqual(1, FEscolhas);
  Assert.AreEqual(2, FNota.Itens[0].ProdutoId);
end;

procedure TTestFaturamentoPedido.PrecoEQuantidadeVemDoPedido;
begin
  // o produto 1 do emissor custa 10,00 no cadastro; vale o preço do pedido
  Assert.IsTrue(Importar);
  Assert.AreEqual(Currency(279.90), FNota.Itens[0].ValorUnitario);
  Assert.AreEqual(Currency(2), FNota.Itens[0].Quantidade);
  Assert.AreEqual(Currency(559.80), FNota.ValorTotal);
end;

procedure TTestFaturamentoPedido.DemaisDadosFiscaisVemDoEmissor;
begin
  Assert.IsTrue(Importar);
  Assert.AreEqual('61091000', FNota.Itens[0].NCM);
  Assert.AreEqual('5102', FNota.Itens[0].CFOP);
  Assert.AreEqual('102', FNota.Itens[0].CstCsosn);
  Assert.AreEqual('PRODUTO 1', FNota.Itens[0].Descricao);
end;

procedure TTestFaturamentoPedido.GravaPedidoEObservacao;
begin
  Assert.IsTrue(Importar);
  Assert.AreEqual(12, FNota.PedidoApiId);
  Assert.AreEqual('Pedido nº 12 (delphi-horse-api)', FNota.Observacao);
  Assert.IsTrue(FLog.Linhas.Text.Contains('Pedido 12 importado'));
end;

procedure TTestFaturamentoPedido.ListarPedidos_PreencheNumeroDaNota;
var
  LPagina: TPaginaPedidosApi;
begin
  FNotaRepo.PedidoFaturado := 12;
  FNotaRepo.NumeroNotaFaturada := 345;
  LPagina := FService.ListarPedidos(1, 20);
  try
    Assert.AreEqual(345, LPagina.Pedidos[0].NotaNumero);
    Assert.AreEqual(0, LPagina.Pedidos[1].NotaNumero);
  finally
    LPagina.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TTestFaturamentoPedido);

end.
