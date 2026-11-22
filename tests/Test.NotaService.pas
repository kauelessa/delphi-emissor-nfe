unit Test.NotaService;

interface

uses
  System.SysUtils, System.Generics.Collections, DUnitX.TestFramework, Model.Tipos, Model.Nota,
  Service.Nota, Service.AvisoFaturamento, Test.Fakes;

type
  // grava as notas avisadas; com LevantarErro simula falha inesperada (ex.: banco fora)
  TAvisoFake = class(TInterfacedObject, IAvisoFaturamento)
  public
    Autorizadas: TList<Integer>;
    Canceladas: TList<Integer>;
    LevantarErro: Boolean;
    constructor Create;
    destructor Destroy; override;
    procedure NotaAutorizada(ANota: TNota);
    procedure NotaCancelada(ANota: TNota);
    function ReenviarPendentes: Integer;
  end;

  [TestFixture]
  TTestNotaService = class
  private
    FNotaRepo: TFakeNotaRepository;
    FEmitenteRepo: TFakeEmitenteRepository;
    FClienteRepo: TFakeClienteRepository;
    FProdutoRepo: TFakeProdutoRepository;
    FEventoRepo: TFakeEventoRepository;
    FEmissor: TFakeEmissor;
    FArquivoXml: TFakeArquivoXml;
    FLog: TFakeLog;
    FService: INotaService;
    FNota: TNota;
    // mantêm os fakes vivos (contagem de referência) enquanto o teste usa os objetos
    FRefs: array of IInterface;
    function NotaPronta(AModelo: TModeloNota): TNota;
    function NotaAutorizada: TNota;
    procedure UsarAviso(AAviso: IAvisoFaturamento);
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    [Test]
    procedure Emitir_Autorizada_AtualizaStatusChaveEProtocolo;
    [Test]
    procedure Emitir_Autorizada_SalvaXmlRegistraEventoELog;
    [Test]
    procedure Emitir_Rejeitada_MantemNumeroParaReenvio;
    [Test]
    procedure Emitir_Denegada_StatusDenegada;
    [Test]
    procedure Emitir_NFeSemDestinatario_NaoTransmite;
    [Test]
    procedure Emitir_PagamentoInsuficiente_NaoTransmite;
    [Test]
    procedure Emitir_CfopInternoParaOutraUF_NaoTransmite;
    [Test]
    procedure Emitir_CstIncompativelComRegime_NaoTransmite;
    [Test]
    procedure Emitir_NFCeSemComunicacao_EntraEmContingencia;
    [Test]
    procedure Emitir_NFeSemComunicacao_ContinuaEmDigitacao;
    [Test]
    procedure Emitir_FalhaDeSchema_NaoRejeitaNota;

    [Test]
    procedure AdicionarItem_ComDescontoAplicado_RedistribuiDesconto;
    [Test]
    procedure AdicionarItem_QuantidadeZero_LevantaExcecao;

    [Test]
    procedure Cancelar_JustificativaCurta_LevantaExcecao;
    [Test]
    procedure Cancelar_NotaAutorizada_StatusCancelada;
    [Test]
    procedure Cancelar_SefazRecusa_MantemAutorizada;
    [Test]
    procedure CartaCorrecao_NFCe_LevantaExcecao;
    [Test]
    procedure CartaCorrecao_LimiteDeVinteCartas_LevantaExcecao;
    [Test]
    procedure Inutilizar_FaixaInvertida_LevantaExcecao;
    [Test]
    procedure Inutilizar_Homologada_RegistraEvento;
    [Test]
    procedure TransmitirContingencia_Autorizada_AtualizaStatus;
    [Test]
    procedure Emitir_NotaAutorizada_AvisaApi;
    [Test]
    procedure Emitir_NotaRejeitada_NaoAvisa;
    [Test]
    procedure Emitir_AvisoLevantaErro_NotaContinuaAutorizada;
    [Test]
    procedure Emitir_ApiForaNoAviso_NotaAutorizadaEPendente;
    [Test]
    procedure Cancelar_Homologado_AvisaCancelamento;
    [Test]
    procedure Cancelar_NaoHomologado_NaoAvisa;
  end;

implementation

uses
  Service.EmissorFiscal, Infra.ApiPedidos, Test.AvisoFaturamento;

{ TAvisoFake }

constructor TAvisoFake.Create;
begin
  inherited;
  Autorizadas := TList<Integer>.Create;
  Canceladas := TList<Integer>.Create;
end;

destructor TAvisoFake.Destroy;
begin
  Canceladas.Free;
  Autorizadas.Free;
  inherited;
end;

procedure TAvisoFake.NotaAutorizada(ANota: TNota);
begin
  if LevantarErro then
    raise Exception.Create('banco fora');
  Autorizadas.Add(ANota.Id);
end;

procedure TAvisoFake.NotaCancelada(ANota: TNota);
begin
  Canceladas.Add(ANota.Id);
end;

function TAvisoFake.ReenviarPendentes: Integer;
begin
  Result := 0;
end;

{ TTestNotaService }

procedure TTestNotaService.Setup;
begin
  FNotaRepo := TFakeNotaRepository.Create;
  FEmitenteRepo := TFakeEmitenteRepository.Create;
  FClienteRepo := TFakeClienteRepository.Create;
  FProdutoRepo := TFakeProdutoRepository.Create;
  FEventoRepo := TFakeEventoRepository.Create;
  FEmissor := TFakeEmissor.Create;
  FArquivoXml := TFakeArquivoXml.Create;
  FLog := TFakeLog.Create;
  FRefs := [FNotaRepo as IInterface, FEmitenteRepo as IInterface, FClienteRepo as IInterface,
    FProdutoRepo as IInterface, FEventoRepo as IInterface, FEmissor as IInterface,
    FArquivoXml as IInterface, FLog as IInterface];

  FService := TNotaService.Create(FNotaRepo, FEmitenteRepo, FClienteRepo, FProdutoRepo,
    TFakeFormaPagamentoRepository.Create, FEventoRepo, FEmissor, FArquivoXml, FLog);
  FNota := nil;
end;

procedure TTestNotaService.TearDown;
begin
  FNota.Free;
  FService := nil;
  FRefs := nil;
end;

function TTestNotaService.NotaPronta(AModelo: TModeloNota): TNota;
begin
  Result := FService.NovaNota(AModelo);
  if AModelo = TModeloNota.NFe then
    Result.ClienteId := 1;
  FService.AdicionarItem(Result, 1, 2);       // 2 x 10,00
  FService.AdicionarPagamento(Result, 1, 20);
end;

function TTestNotaService.NotaAutorizada: TNota;
begin
  Result := TNota.Create;
  Result.Id := 10;
  Result.Modelo := TModeloNota.NFe;
  Result.Serie := 1;
  Result.Numero := 5;
  Result.Status := TStatusNota.Autorizada;
  Result.Chave := CHAVE_TESTE;
  Result.Protocolo := '135260000000001';
  Result.ArquivoXml := 'arquivo.xml';
end;

procedure TTestNotaService.Emitir_Autorizada_AtualizaStatusChaveEProtocolo;
var
  LResultado: TResultadoOperacao;
begin
  FNota := NotaPronta(TModeloNota.NFe);
  LResultado := FService.Emitir(FNota);

  Assert.IsTrue(LResultado.Sucesso, LResultado.Mensagem);
  Assert.AreEqual(TStatusNota.Autorizada, FNota.Status);
  Assert.AreEqual(CHAVE_TESTE, FNota.Chave);
  Assert.AreEqual('135260000000001', FNota.Protocolo);
  Assert.AreEqual(1, FNota.Numero);
  Assert.AreEqual(TStatusNota.Autorizada, FNotaRepo.UltimoStatus);
end;

procedure TTestNotaService.Emitir_Autorizada_SalvaXmlRegistraEventoELog;
begin
  FNota := NotaPronta(TModeloNota.NFe);
  FService.Emitir(FNota);

  Assert.IsTrue(FArquivoXml.Arquivos.ContainsKey('11222333000181\' + CHAVE_TESTE + '-env.xml'), 'XML de envio');
  Assert.IsTrue(FArquivoXml.Arquivos.ContainsKey('11222333000181\' + CHAVE_TESTE + '-nfe.xml'), 'XML autorizado');
  Assert.AreEqual(FNota.ArquivoXml, '11222333000181\' + CHAVE_TESTE + '-nfe.xml');

  Assert.AreEqual(1, FEventoRepo.Eventos.Count);
  Assert.AreEqual(TTipoEventoFiscal.Emissao, FEventoRepo.Eventos[0].Tipo);
  Assert.IsTrue(FEventoRepo.Eventos[0].Sucesso);
  Assert.IsTrue(FLog.ContemFiscal('cStat 100'), FLog.Linhas.Text);
end;

procedure TTestNotaService.Emitir_Rejeitada_MantemNumeroParaReenvio;
var
  LResultado: TResultadoOperacao;
begin
  FEmissor.RetornoTransmissao.CStat := 778;
  FEmissor.RetornoTransmissao.Motivo := 'Rejeicao: Informado NCM inexistente';
  FEmissor.RetornoTransmissao.Protocolo := '';
  FEmissor.RetornoTransmissao.XmlRetorno := '';
  FNota := NotaPronta(TModeloNota.NFe);

  LResultado := FService.Emitir(FNota);
  Assert.IsFalse(LResultado.Sucesso);
  Assert.AreEqual(TStatusNota.Rejeitada, FNota.Status);
  Assert.Contains(LResultado.Mensagem, 'NCM');

  // corrigiu e reenviou: mesmo número, nenhuma nova reserva
  FEmissor.RetornoTransmissao.CStat := 100;
  FEmissor.RetornoTransmissao.Protocolo := '135260000000009';
  LResultado := FService.Emitir(FNota);
  Assert.IsTrue(LResultado.Sucesso, LResultado.Mensagem);
  Assert.AreEqual(1, FNota.Numero);
  Assert.AreEqual(1, FEmitenteRepo.Reservas);
end;

procedure TTestNotaService.Emitir_Denegada_StatusDenegada;
begin
  FEmissor.RetornoTransmissao.CStat := 302;
  FEmissor.RetornoTransmissao.Motivo := 'Uso Denegado: Irregularidade fiscal do destinatario';
  FNota := NotaPronta(TModeloNota.NFe);

  Assert.IsFalse(FService.Emitir(FNota).Sucesso);
  Assert.AreEqual(TStatusNota.Denegada, FNota.Status);
end;

procedure TTestNotaService.Emitir_NFeSemDestinatario_NaoTransmite;
var
  LResultado: TResultadoOperacao;
begin
  FNota := NotaPronta(TModeloNota.NFe);
  FNota.ClienteId := 0;

  LResultado := FService.Emitir(FNota);
  Assert.IsFalse(LResultado.Sucesso);
  Assert.Contains(LResultado.Mensagem, 'destinatário');
  Assert.AreEqual(0, FEmissor.Transmissoes);
  Assert.AreEqual(0, FEmitenteRepo.Reservas, 'não pode consumir numeração');
end;

procedure TTestNotaService.Emitir_PagamentoInsuficiente_NaoTransmite;
begin
  FNota := FService.NovaNota(TModeloNota.NFCe);
  FService.AdicionarItem(FNota, 1, 3);   // 30,00
  FService.AdicionarPagamento(FNota, 1, 20);

  Assert.IsFalse(FService.Emitir(FNota).Sucesso);
  Assert.AreEqual(0, FEmissor.Transmissoes);
end;

procedure TTestNotaService.Emitir_CfopInternoParaOutraUF_NaoTransmite;
var
  LResultado: TResultadoOperacao;
begin
  FClienteRepo.UF := 'RJ';
  FNota := NotaPronta(TModeloNota.NFe);

  LResultado := FService.Emitir(FNota);
  Assert.IsFalse(LResultado.Sucesso);
  Assert.Contains(LResultado.Mensagem, 'esperado 6xxx');
end;

procedure TTestNotaService.Emitir_CstIncompativelComRegime_NaoTransmite;
var
  LResultado: TResultadoOperacao;
begin
  FEmitenteRepo.Regime := TRegimeTributario.RegimeNormal;  // exige CST de 2 dígitos
  FNota := NotaPronta(TModeloNota.NFe);                    // produto usa CSOSN 102

  LResultado := FService.Emitir(FNota);
  Assert.IsFalse(LResultado.Sucesso);
  Assert.Contains(LResultado.Mensagem, 'regime normal');
end;

procedure TTestNotaService.Emitir_NFCeSemComunicacao_EntraEmContingencia;
var
  LResultado: TResultadoOperacao;
begin
  FEmissor.RetornoTransmissao := TRetornoFiscal.Erro('Timeout', True);
  FNota := NotaPronta(TModeloNota.NFCe);

  LResultado := FService.Emitir(FNota);
  Assert.IsTrue(LResultado.Sucesso, LResultado.Mensagem);
  Assert.IsTrue(FEmissor.GerouContingencia);
  Assert.AreEqual(TStatusNota.Contingencia, FNota.Status);
  Assert.IsTrue(FNota.Contingencia);
  Assert.AreEqual(TTipoEventoFiscal.Contingencia, FEventoRepo.Eventos.Last.Tipo);
end;

procedure TTestNotaService.Emitir_NFeSemComunicacao_ContinuaEmDigitacao;
var
  LResultado: TResultadoOperacao;
begin
  FEmissor.RetornoTransmissao := TRetornoFiscal.Erro('Timeout', True);
  FNota := NotaPronta(TModeloNota.NFe);

  LResultado := FService.Emitir(FNota);
  Assert.IsFalse(LResultado.Sucesso);
  Assert.IsFalse(FEmissor.GerouContingencia, 'NF-e não usa contingência offline');
  Assert.AreEqual(TStatusNota.Digitacao, FNota.Status);
  Assert.Contains(LResultado.Mensagem, 'Sem comunicação');
end;

procedure TTestNotaService.Emitir_FalhaDeSchema_NaoRejeitaNota;
begin
  FEmissor.RetornoTransmissao := TRetornoFiscal.Erro('Falha na validação do XML: campo xNome');
  FNota := NotaPronta(TModeloNota.NFe);

  Assert.IsFalse(FService.Emitir(FNota).Sucesso);
  Assert.AreEqual(TStatusNota.Digitacao, FNota.Status);
end;

procedure TTestNotaService.AdicionarItem_ComDescontoAplicado_RedistribuiDesconto;
begin
  FNota := FService.NovaNota(TModeloNota.NFCe);
  FService.AdicionarItem(FNota, 1, 1);        // 10,00
  FService.AplicarDesconto(FNota, 4.33);
  FService.AdicionarItem(FNota, 2, 1);        // 33,33

  Assert.AreEqual(Currency(4.33), FNota.ValorDesconto);
  Assert.AreEqual(Currency(1.00), FNota.Itens[0].ValorDesconto);  // 4,33 x 10/43,33
  Assert.AreEqual(Currency(3.33), FNota.Itens[1].ValorDesconto);
  Assert.AreEqual(Currency(39.00), FNota.ValorTotal);
end;

procedure TTestNotaService.AdicionarItem_QuantidadeZero_LevantaExcecao;
begin
  FNota := FService.NovaNota(TModeloNota.NFCe);
  Assert.WillRaise(
    procedure
    begin
      FService.AdicionarItem(FNota, 1, 0);
    end, EValidacao);
end;

procedure TTestNotaService.Cancelar_JustificativaCurta_LevantaExcecao;
begin
  FNotaRepo.CriarNotaObter := NotaAutorizada;
  Assert.WillRaise(
    procedure
    begin
      FService.Cancelar(10, 'muito curta');
    end, EValidacao);
end;

procedure TTestNotaService.Cancelar_NotaAutorizada_StatusCancelada;
var
  LResultado: TResultadoOperacao;
begin
  FNotaRepo.CriarNotaObter := NotaAutorizada;
  LResultado := FService.Cancelar(10, 'Cliente desistiu da compra');

  Assert.IsTrue(LResultado.Sucesso, LResultado.Mensagem);
  Assert.AreEqual(TStatusNota.Cancelada, FNotaRepo.UltimoStatus);
  Assert.AreEqual(TTipoEventoFiscal.Cancelamento, FEventoRepo.Eventos[0].Tipo);
  Assert.IsTrue(FArquivoXml.Arquivos.ContainsKey('11222333000181\' + CHAVE_TESTE + '-can.xml'));
end;

procedure TTestNotaService.Cancelar_SefazRecusa_MantemAutorizada;
var
  LResultado: TResultadoOperacao;
begin
  FEmissor.RetornoEvento.CStat := 501;
  FEmissor.RetornoEvento.Motivo := 'Rejeicao: Prazo de cancelamento superior ao previsto';
  FNotaRepo.CriarNotaObter := NotaAutorizada;

  LResultado := FService.Cancelar(10, 'Cliente desistiu da compra');
  Assert.IsFalse(LResultado.Sucesso);
  Assert.AreEqual(0, FNotaRepo.Atualizacoes, 'status não pode mudar');
  Assert.IsFalse(FEventoRepo.Eventos[0].Sucesso);
end;

procedure TTestNotaService.CartaCorrecao_NFCe_LevantaExcecao;
begin
  FNotaRepo.CriarNotaObter :=
    function: TNota
    begin
      Result := NotaAutorizada;
      Result.Modelo := TModeloNota.NFCe;
    end;
  Assert.WillRaise(
    procedure
    begin
      FService.CartaCorrecao(10, 'Correção do endereço de entrega');
    end, EValidacao);
end;

procedure TTestNotaService.CartaCorrecao_LimiteDeVinteCartas_LevantaExcecao;
begin
  FNotaRepo.CriarNotaObter := NotaAutorizada;
  FEventoRepo.SequenciaCCe := 21;
  Assert.WillRaise(
    procedure
    begin
      FService.CartaCorrecao(10, 'Correção do endereço de entrega');
    end, EValidacao);
end;

procedure TTestNotaService.Inutilizar_FaixaInvertida_LevantaExcecao;
begin
  Assert.WillRaise(
    procedure
    begin
      FService.Inutilizar(TModeloNota.NFe, 1, 10, 5, 'Falha no sistema ao numerar');
    end, EValidacao);
end;

procedure TTestNotaService.Inutilizar_Homologada_RegistraEvento;
var
  LResultado: TResultadoOperacao;
begin
  LResultado := FService.Inutilizar(TModeloNota.NFCe, 1, 3, 4, 'Falha no sistema ao numerar');
  Assert.IsTrue(LResultado.Sucesso, LResultado.Mensagem);
  Assert.AreEqual(TTipoEventoFiscal.Inutilizacao, FEventoRepo.Eventos[0].Tipo);
  Assert.IsTrue(FLog.ContemFiscal('Inutiliza'), FLog.Linhas.Text);
end;

procedure TTestNotaService.TransmitirContingencia_Autorizada_AtualizaStatus;
var
  LResultado: TResultadoOperacao;
begin
  FNotaRepo.CriarNotaObter :=
    function: TNota
    begin
      Result := NotaAutorizada;
      Result.Modelo := TModeloNota.NFCe;
      Result.Status := TStatusNota.Contingencia;
      Result.Contingencia := True;
    end;

  LResultado := FService.TransmitirContingencia(10);
  Assert.IsTrue(LResultado.Sucesso, LResultado.Mensagem);
  Assert.AreEqual(TStatusNota.Autorizada, FNotaRepo.UltimoStatus);
  Assert.AreEqual(1, FEmissor.Transmissoes);
end;

procedure TTestNotaService.UsarAviso(AAviso: IAvisoFaturamento);
begin
  FService := TNotaService.Create(FNotaRepo, FEmitenteRepo, FClienteRepo, FProdutoRepo,
    TFakeFormaPagamentoRepository.Create, FEventoRepo, FEmissor, FArquivoXml, FLog, AAviso);
end;

procedure TTestNotaService.Emitir_NotaAutorizada_AvisaApi;
var
  LAviso: TAvisoFake;
begin
  LAviso := TAvisoFake.Create;
  UsarAviso(LAviso);
  FNota := NotaPronta(TModeloNota.NFe);
  FNota.PedidoApiId := 12;
  Assert.IsTrue(FService.Emitir(FNota).Sucesso);
  Assert.AreEqual(1, LAviso.Autorizadas.Count);
  Assert.AreEqual(FNota.Id, LAviso.Autorizadas[0]);
end;

procedure TTestNotaService.Emitir_NotaRejeitada_NaoAvisa;
var
  LAviso: TAvisoFake;
begin
  LAviso := TAvisoFake.Create;
  UsarAviso(LAviso);
  FEmissor.RetornoTransmissao.CStat := 778;
  FEmissor.RetornoTransmissao.Motivo := 'Rejeicao: Informado NCM inexistente';
  FNota := NotaPronta(TModeloNota.NFe);
  FNota.PedidoApiId := 12;
  Assert.IsFalse(FService.Emitir(FNota).Sucesso);
  Assert.AreEqual(0, LAviso.Autorizadas.Count);
end;

procedure TTestNotaService.Emitir_AvisoLevantaErro_NotaContinuaAutorizada;
var
  LAviso: TAvisoFake;
  LResultado: TResultadoOperacao;
begin
  LAviso := TAvisoFake.Create;
  LAviso.LevantarErro := True;
  UsarAviso(LAviso);
  FNota := NotaPronta(TModeloNota.NFe);
  FNota.PedidoApiId := 12;
  LResultado := FService.Emitir(FNota);
  Assert.IsTrue(LResultado.Sucesso, LResultado.Mensagem);
  Assert.AreEqual(TStatusNota.Autorizada, FNota.Status);
  Assert.IsTrue(FLog.Linhas.Text.Contains('banco fora'), FLog.Linhas.Text);
end;

procedure TTestNotaService.Emitir_ApiForaNoAviso_NotaAutorizadaEPendente;
var
  LApi: TApiAvisoFake;
  LResultado: TResultadoOperacao;
begin
  LApi := TApiAvisoFake.Create;
  LApi.SempreIndisponivel := True;
  UsarAviso(TAvisoFaturamentoService.Create(LApi, FNotaRepo, FLog));
  FNota := NotaPronta(TModeloNota.NFe);
  FNota.PedidoApiId := 12;
  LResultado := FService.Emitir(FNota);
  Assert.IsTrue(LResultado.Sucesso, LResultado.Mensagem);
  Assert.StartsWith('NF-e nº 1 autorizada.', LResultado.Mensagem);
  Assert.DoesNotContain(LResultado.Mensagem, 'API');
  Assert.AreEqual(TStatusNota.Autorizada, FNota.Status);
  Assert.IsTrue(FNotaRepo.Pendente(FNota.Id));
end;

procedure TTestNotaService.Cancelar_Homologado_AvisaCancelamento;
var
  LAviso: TAvisoFake;
begin
  LAviso := TAvisoFake.Create;
  UsarAviso(LAviso);
  FNotaRepo.CriarNotaObter := NotaAutorizada;
  Assert.IsTrue(FService.Cancelar(10, 'Cliente desistiu da compra').Sucesso);
  Assert.AreEqual(1, LAviso.Canceladas.Count);
  Assert.AreEqual(10, LAviso.Canceladas[0]);
end;

procedure TTestNotaService.Cancelar_NaoHomologado_NaoAvisa;
var
  LAviso: TAvisoFake;
begin
  LAviso := TAvisoFake.Create;
  UsarAviso(LAviso);
  FEmissor.RetornoEvento.CStat := 501;
  FEmissor.RetornoEvento.Motivo := 'Rejeicao: Prazo de cancelamento superior ao previsto';
  FNotaRepo.CriarNotaObter := NotaAutorizada;
  Assert.IsFalse(FService.Cancelar(10, 'Cliente desistiu da compra').Sucesso);
  Assert.AreEqual(0, LAviso.Canceladas.Count);
end;

initialization
  TDUnitX.RegisterTestFixture(TTestNotaService);

end.
