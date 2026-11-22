unit Test.ApiPedidos;

interface

uses
  System.SysUtils, System.Generics.Collections, System.Net.HttpClient, DUnitX.TestFramework, Model.PedidoApi,
  Infra.ApiPedidos;

type
  TChamada = record
    Metodo, Url, Corpo, Token: string;
  end;

  // devolve as respostas na ordem em que foram enfileiradas e guarda o que recebeu
  TTransporteFake = class(TInterfacedObject, IHttpTransporte)
  public
    Respostas: TQueue<THttpResposta>;
    Chamadas: TList<TChamada>;
    constructor Create;
    destructor Destroy; override;
    procedure Responder(AStatus: Integer; const ACorpo: string);
    function Executar(const AMetodo, AUrl, ACorpo, AToken: string): THttpResposta;
  end;

  [TestFixture]
  TTestApiPedidos = class
  private
    FTransporte: TTransporteFake;
    FApi: IPedidoApi;
    procedure ResponderLogin(const AToken: string = 'tk1');
  public
    [Setup]
    procedure Setup;
    [Test]
    procedure Obter_ConvertePedidoComItens;
    [Test]
    procedure Obter_PrecoComPontoEmWindowsPtBr;
    [Test]
    procedure Obter_StatusCancelado;
    [Test]
    procedure PrimeiraChamada_FazLoginEEnviaToken;
    [Test]
    procedure SegundaChamada_ReaproveitaToken;
    [Test]
    procedure Resposta401_RelogaERepeteUmaVez;
    [Test]
    procedure Resposta401DuasVezes_LevantaErro;
    [Test]
    procedure Erro404_UsaMensagemDaApi;
    [Test]
    procedure ErroSemCorpo_MensagemComStatus;
    [Test]
    procedure Listar_LePagina;
    [Test]
    procedure ObterCliente_LeDados;
    [Test]
    procedure FalhaDeConexao_MensagemComUrl;
    [Test]
    procedure Faturar_EnviaPatchComDadosDaNota;
    [Test]
    procedure RemoverFaturamento_EnviaDelete;
    [Test]
    procedure Faturar_401_RelogaERepete;
    [Test]
    procedure Faturar_409_LevantaRecusadoComMensagemDaApi;
    [Test]
    procedure Faturar_500_LevantaIndisponivel;
    [Test]
    procedure FalhaDeConexao_LevantaIndisponivel;
  end;

implementation

uses
  System.JSON, System.DateUtils;

const
  URL = 'http://localhost:9000';
  CHAVE_44 = '35261111222333000181550010000001231000001230';
  PEDIDO_12 =
    '{"id":12,"cliente":{"id":3,"nome":"Maria Souza"},"data":"2026-11-20T10:30:00",' +
    '"status":"ABERTO","valorTotal":559.8,"itens":[{"id":1,"produtoId":7,' +
    '"descricao":"Teclado","quantidade":2,"precoUnitario":279.9,"valorTotal":559.8}]}';

{ TTransporteFake }

constructor TTransporteFake.Create;
begin
  inherited;
  Respostas := TQueue<THttpResposta>.Create;
  Chamadas := TList<TChamada>.Create;
end;

destructor TTransporteFake.Destroy;
begin
  Respostas.Free;
  Chamadas.Free;
  inherited;
end;

procedure TTransporteFake.Responder(AStatus: Integer; const ACorpo: string);
var
  LResp: THttpResposta;
begin
  LResp.Status := AStatus;
  LResp.Corpo := ACorpo;
  Respostas.Enqueue(LResp);
end;

function TTransporteFake.Executar(const AMetodo, AUrl, ACorpo, AToken: string): THttpResposta;
var
  LChamada: TChamada;
begin
  LChamada.Metodo := AMetodo;
  LChamada.Url := AUrl;
  LChamada.Corpo := ACorpo;
  LChamada.Token := AToken;
  Chamadas.Add(LChamada);
  if Respostas.Count = 0 then
    raise Exception.Create('fake sem resposta para ' + AUrl);
  Result := Respostas.Dequeue;
  // status 0 simula a API fora do ar
  if Result.Status = 0 then
    raise ENetHTTPClientException.Create('Não foi possível conectar ao servidor');
end;

{ TTestApiPedidos }

procedure TTestApiPedidos.Setup;
begin
  FTransporte := TTransporteFake.Create;
  FApi := TPedidoApiHttp.Create(FTransporte, URL, 'admin', 'segredo');
end;

procedure TTestApiPedidos.ResponderLogin(const AToken: string);
begin
  FTransporte.Responder(200, '{"token":"' + AToken + '","expiraEm":"2026-11-22T12:00:00"}');
end;

procedure TTestApiPedidos.Obter_ConvertePedidoComItens;
var
  LPedido: TPedidoApi;
begin
  ResponderLogin;
  FTransporte.Responder(200, PEDIDO_12);
  LPedido := FApi.Obter(12);
  try
    Assert.AreEqual(12, LPedido.Id);
    Assert.AreEqual(3, LPedido.ClienteId);
    Assert.AreEqual('Maria Souza', LPedido.ClienteNome);
    Assert.AreEqual(TStatusPedidoApi.Aberto, LPedido.Status);
    Assert.AreEqual(Currency(559.80), LPedido.ValorTotal);
    Assert.AreEqual(1, LPedido.Itens.Count);
    Assert.AreEqual(7, LPedido.Itens[0].ProdutoId);
    Assert.AreEqual('Teclado', LPedido.Itens[0].Descricao);
    Assert.AreEqual(2, LPedido.Itens[0].Quantidade);
    Assert.AreEqual(Currency(279.90), LPedido.Itens[0].PrecoUnitario);
    Assert.AreEqual(URL + '/pedidos/12', FTransporte.Chamadas[1].Url);
  finally
    LPedido.Free;
  end;
end;

procedure TTestApiPedidos.Obter_PrecoComPontoEmWindowsPtBr;
var
  LPedido: TPedidoApi;
  LSeparador: Char;
begin
  LSeparador := FormatSettings.DecimalSeparator;
  FormatSettings.DecimalSeparator := ',';
  try
    ResponderLogin;
    FTransporte.Responder(200, PEDIDO_12);
    LPedido := FApi.Obter(12);
    try
      Assert.AreEqual(Currency(279.90), LPedido.Itens[0].PrecoUnitario);
    finally
      LPedido.Free;
    end;
  finally
    FormatSettings.DecimalSeparator := LSeparador;
  end;
end;

procedure TTestApiPedidos.Obter_StatusCancelado;
var
  LPedido: TPedidoApi;
begin
  ResponderLogin;
  FTransporte.Responder(200, StringReplace(PEDIDO_12, '"ABERTO"', '"CANCELADO"', []));
  LPedido := FApi.Obter(12);
  try
    Assert.AreEqual(TStatusPedidoApi.Cancelado, LPedido.Status);
  finally
    LPedido.Free;
  end;
end;

procedure TTestApiPedidos.PrimeiraChamada_FazLoginEEnviaToken;
begin
  ResponderLogin('abc');
  FTransporte.Responder(200, PEDIDO_12);
  FApi.Obter(12).Free;
  Assert.AreEqual('POST', FTransporte.Chamadas[0].Metodo);
  Assert.AreEqual(URL + '/auth/login', FTransporte.Chamadas[0].Url);
  Assert.Contains(FTransporte.Chamadas[0].Corpo, '"login":"admin"');
  Assert.Contains(FTransporte.Chamadas[0].Corpo, '"senha":"segredo"');
  Assert.AreEqual('GET', FTransporte.Chamadas[1].Metodo);
  Assert.AreEqual('abc', FTransporte.Chamadas[1].Token);
end;

procedure TTestApiPedidos.SegundaChamada_ReaproveitaToken;
begin
  ResponderLogin;
  FTransporte.Responder(200, PEDIDO_12);
  FTransporte.Responder(200, PEDIDO_12);
  FApi.Obter(12).Free;
  FApi.Obter(12).Free;
  Assert.AreEqual(3, FTransporte.Chamadas.Count);
end;

procedure TTestApiPedidos.Resposta401_RelogaERepeteUmaVez;
var
  LPedido: TPedidoApi;
begin
  ResponderLogin('velho');
  FTransporte.Responder(401, '{"erro":"Token expirado."}');
  ResponderLogin('novo');
  FTransporte.Responder(200, PEDIDO_12);
  LPedido := FApi.Obter(12);
  try
    Assert.AreEqual(12, LPedido.Id);
    Assert.AreEqual(4, FTransporte.Chamadas.Count);
    Assert.AreEqual('novo', FTransporte.Chamadas[3].Token);
  finally
    LPedido.Free;
  end;
end;

procedure TTestApiPedidos.Resposta401DuasVezes_LevantaErro;
begin
  ResponderLogin;
  FTransporte.Responder(401, '{"erro":"Token expirado."}');
  ResponderLogin;
  FTransporte.Responder(401, '{"erro":"Token inválido."}');
  Assert.WillRaise(
    procedure
    begin
      FApi.Obter(12).Free;
    end, EApiPedidos);
  Assert.AreEqual(4, FTransporte.Chamadas.Count);
end;

procedure TTestApiPedidos.Erro404_UsaMensagemDaApi;
begin
  ResponderLogin;
  FTransporte.Responder(404, '{"erro":"Pedido 99 não encontrado."}');
  Assert.WillRaiseWithMessage(
    procedure
    begin
      FApi.Obter(99).Free;
    end, EApiPedidoRecusado, 'Pedido 99 não encontrado.');
end;

procedure TTestApiPedidos.ErroSemCorpo_MensagemComStatus;
begin
  ResponderLogin;
  FTransporte.Responder(500, '');
  Assert.WillRaiseWithMessage(
    procedure
    begin
      FApi.Obter(12).Free;
    end, EApiIndisponivel, 'A API respondeu 500.');
end;

procedure TTestApiPedidos.Listar_LePagina;
var
  LPagina: TPaginaPedidosApi;
begin
  ResponderLogin;
  FTransporte.Responder(200, '{"pagina":2,"limite":20,"total":45,"dados":[' +
    '{"id":21,"cliente":{"id":3,"nome":"Maria Souza"},"data":"2026-11-20T10:30:00","status":"ABERTO","valorTotal":10.5},' +
    '{"id":20,"cliente":{"id":4,"nome":"João Lima"},"data":"2026-11-19T09:00:00","status":"CANCELADO","valorTotal":99.9}]}');
  LPagina := FApi.Listar(2, 20);
  try
    Assert.AreEqual(URL + '/pedidos?pagina=2&limite=20', FTransporte.Chamadas[1].Url);
    Assert.AreEqual(2, LPagina.Pagina);
    Assert.AreEqual(45, LPagina.Total);
    Assert.AreEqual(3, LPagina.TotalPaginas(20));
    Assert.AreEqual(2, LPagina.Pedidos.Count);
    Assert.AreEqual('João Lima', LPagina.Pedidos[1].ClienteNome);
    Assert.AreEqual(Currency(99.90), LPagina.Pedidos[1].ValorTotal);
    Assert.AreEqual(TStatusPedidoApi.Cancelado, LPagina.Pedidos[1].Status);
  finally
    LPagina.Free;
  end;
end;

procedure TTestApiPedidos.ObterCliente_LeDados;
var
  LCliente: TClienteApi;
begin
  ResponderLogin;
  FTransporte.Responder(200, '{"id":3,"nome":"Maria Souza","documento":"52998224725",' +
    '"email":"maria@exemplo.com","telefone":"11999990000"}');
  LCliente := FApi.ObterCliente(3);
  try
    Assert.AreEqual(URL + '/clientes/3', FTransporte.Chamadas[1].Url);
    Assert.AreEqual('Maria Souza', LCliente.Nome);
    Assert.AreEqual('52998224725', LCliente.Documento);
    Assert.AreEqual('maria@exemplo.com', LCliente.Email);
    Assert.AreEqual('11999990000', LCliente.Telefone);
  finally
    LCliente.Free;
  end;
end;

procedure TTestApiPedidos.FalhaDeConexao_MensagemComUrl;
begin
  FTransporte.Responder(0, '');
  Assert.WillRaiseWithMessage(
    procedure
    begin
      FApi.Obter(12).Free;
    end, EApiIndisponivel, 'Não foi possível conectar à API em http://localhost:9000.');
end;

procedure TTestApiPedidos.Faturar_EnviaPatchComDadosDaNota;
var
  LData: TDateTime;
  LCorpo: TJSONObject;
begin
  LData := EncodeDateTime(2026, 11, 22, 14, 5, 0, 0);
  ResponderLogin;
  FTransporte.Responder(200, PEDIDO_12);
  FApi.Faturar(12, 123, 1, CHAVE_44, LData);

  Assert.AreEqual(2, FTransporte.Chamadas.Count);
  Assert.AreEqual('PATCH', FTransporte.Chamadas[1].Metodo);
  Assert.AreEqual(URL + '/pedidos/12/faturamento', FTransporte.Chamadas[1].Url);
  Assert.AreEqual('tk1', FTransporte.Chamadas[1].Token);
  LCorpo := TJSONObject.ParseJSONValue(FTransporte.Chamadas[1].Corpo) as TJSONObject;
  try
    Assert.AreEqual(123, LCorpo.GetValue<Integer>('numero'));
    Assert.AreEqual(1, LCorpo.GetValue<Integer>('serie'));
    Assert.AreEqual(CHAVE_44, LCorpo.GetValue<string>('chave'));
    Assert.AreEqual(DateToISO8601(LData, False), LCorpo.GetValue<string>('autorizadaEm'));
  finally
    LCorpo.Free;
  end;
end;

procedure TTestApiPedidos.RemoverFaturamento_EnviaDelete;
begin
  ResponderLogin;
  FTransporte.Responder(200, PEDIDO_12);
  FApi.RemoverFaturamento(12);
  Assert.AreEqual('DELETE', FTransporte.Chamadas[1].Metodo);
  Assert.AreEqual(URL + '/pedidos/12/faturamento', FTransporte.Chamadas[1].Url);
end;

procedure TTestApiPedidos.Faturar_401_RelogaERepete;
begin
  ResponderLogin('velho');
  FTransporte.Responder(401, '{"erro":"Token expirado."}');
  ResponderLogin('novo');
  FTransporte.Responder(200, PEDIDO_12);
  FApi.Faturar(12, 123, 1, CHAVE_44, Now);
  Assert.AreEqual(4, FTransporte.Chamadas.Count);
  Assert.AreEqual('PATCH', FTransporte.Chamadas[3].Metodo);
  Assert.AreEqual('novo', FTransporte.Chamadas[3].Token);
end;

procedure TTestApiPedidos.Faturar_409_LevantaRecusadoComMensagemDaApi;
begin
  ResponderLogin;
  FTransporte.Responder(409, '{"erro":"Pedido cancelado não pode ser faturado."}');
  Assert.WillRaiseWithMessage(
    procedure
    begin
      FApi.Faturar(12, 123, 1, CHAVE_44, Now);
    end, EApiPedidoRecusado, 'Pedido cancelado não pode ser faturado.');
end;

procedure TTestApiPedidos.Faturar_500_LevantaIndisponivel;
begin
  ResponderLogin;
  FTransporte.Responder(500, '{"erro":"Erro interno."}');
  Assert.WillRaise(
    procedure
    begin
      FApi.Faturar(12, 123, 1, CHAVE_44, Now);
    end, EApiIndisponivel);
end;

procedure TTestApiPedidos.FalhaDeConexao_LevantaIndisponivel;
begin
  FTransporte.Responder(0, '');
  Assert.WillRaiseWithMessage(
    procedure
    begin
      FApi.Faturar(12, 123, 1, CHAVE_44, Now);
    end, EApiIndisponivel, 'Não foi possível conectar à API em http://localhost:9000.');
end;

initialization
  TDUnitX.RegisterTestFixture(TTestApiPedidos);

end.
