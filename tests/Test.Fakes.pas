unit Test.Fakes;

// Fakes dos repositórios, do emissor (SEFAZ), do log e do armazenamento de XML.
// Tudo em memória, para os testes do TNotaService rodarem sem banco e sem ACBr.

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections, Model.Tipos, Model.Nota,
  Model.Emitente, Model.Cliente, Model.Produto, Model.FormaPagamento, Model.EventoFiscal,
  Repository.Nota, Repository.Emitente, Repository.Cliente, Repository.Produto,
  Repository.FormaPagamento, Repository.EventoFiscal, Repository.VinculoProduto, Service.EmissorFiscal,
  Infra.ArquivoXml, Infra.Log;

type
  TFakeNotaRepository = class(TInterfacedObject, INotaRepository)
  public
    ProximoId: Integer;
    Salvamentos: Integer;
    Atualizacoes: Integer;
    UltimoStatus: TStatusNota;
    // a nota devolvida por Obter é criada a cada chamada (o service libera)
    CriarNotaObter: TFunc<TNota>;
    // pedido da API que já tem nota autorizada (0 = nenhum) e o número dessa nota
    PedidoFaturado: Integer;
    NumeroNotaFaturada: Integer;
    // notas que o aviso de faturamento consulta; a pendência fica em Pendencias
    Notas: TObjectList<TNota>;
    Pendencias: TDictionary<Integer, Boolean>;
    constructor Create;
    destructor Destroy; override;
    /// Guarda uma cópia do cabeçalho da nota (como se estivesse no banco).
    procedure Guardar(ANota: TNota; APendente: Boolean = False);
    function Pendente(ANotaId: Integer): Boolean;
    procedure Salvar(ANota: TNota);
    procedure AtualizarSituacao(ANota: TNota);
    function Obter(AId: Integer): TNota;
    function Listar(const AFiltro: TFiltroNota): TObjectList<TNota>;
    function ObterFaturadaDoPedido(APedidoApiId: Integer): TNota;
    procedure MarcarFaturamentoPendente(ANotaId: Integer; APendente: Boolean);
    function ListarFaturamentoPendente: TObjectList<TNota>;
  end;

  TFakeEmitenteRepository = class(TInterfacedObject, IEmitenteRepository)
  public
    Regime: TRegimeTributario;
    ProximoNumero: Integer;
    Reservas: Integer;
    constructor Create;
    function Obter: TEmitente;
    procedure Salvar(AEmitente: TEmitente);
    function ReservarNumero(AModelo: TModeloNota): Integer;
  end;

  TFakeClienteRepository = class(TInterfacedObject, IClienteRepository)
  public
    UF: string;
    function Listar(const AFiltro: string): TObjectList<TCliente>;
    function Obter(AId: Integer): TCliente;
    function ObterPorDocumento(const ADocumento: string): TCliente;
    procedure Salvar(ACliente: TCliente);
    procedure Inativar(AId: Integer);
  end;

  TFakeProdutoRepository = class(TInterfacedObject, IProdutoRepository)
  public
    CstCsosn: string;
    InativoId: Integer;
    constructor Create;
    function Listar(const AFiltro: string): TObjectList<TProduto>;
    function Obter(AId: Integer): TProduto;
    function ObterPorCodigo(const ACodigo: string): TProduto;
    procedure Salvar(AProduto: TProduto);
    procedure Inativar(AId: Integer);
  end;

  TFakeVinculoRepository = class(TInterfacedObject, IVinculoProdutoRepository)
  public
    Vinculos: TDictionary<Integer, Integer>;
    constructor Create;
    destructor Destroy; override;
    function ProdutoDoEmissor(AApiProdutoId: Integer): Integer;
    procedure Gravar(AApiProdutoId, AProdutoId: Integer);
  end;

  TFakeFormaPagamentoRepository = class(TInterfacedObject, IFormaPagamentoRepository)
  public
    function Listar(AApenasAtivas: Boolean = True): TObjectList<TFormaPagamento>;
    function Obter(AId: Integer): TFormaPagamento;
    procedure Salvar(AForma: TFormaPagamento);
  end;

  TEventoRegistrado = record
    Tipo: TTipoEventoFiscal;
    Sucesso: Boolean;
    CStat: Integer;
    ArquivoXml: string;
  end;

  TFakeEventoRepository = class(TInterfacedObject, IEventoFiscalRepository)
  public
    Eventos: TList<TEventoRegistrado>;
    SequenciaCCe: Integer;
    constructor Create;
    destructor Destroy; override;
    procedure Registrar(AEvento: TEventoFiscal);
    function ListarPorNota(ANotaId: Integer): TObjectList<TEventoFiscal>;
    function ProximaSequenciaCCe(ANotaId: Integer): Integer;
  end;

  TFakeEmissor = class(TInterfacedObject, IEmissorFiscal)
  public
    RetornoTransmissao: TRetornoFiscal;
    RetornoContingencia: TRetornoFiscal;
    RetornoEvento: TRetornoFiscal;
    Transmissoes: Integer;
    GerouContingencia: Boolean;
    constructor Create;
    function StatusServico(AModelo: TModeloNota): TRetornoFiscal;
    function Transmitir(ANota: TNota; AEmitente: TEmitente; ADestinatario: TCliente;
      AContingencia: Boolean): TRetornoFiscal;
    function TransmitirXml(const AXml: string; AModelo: TModeloNota): TRetornoFiscal;
    function Cancelar(ANota: TNota; const ACnpjEmitente, AJustificativa: string): TRetornoFiscal;
    function CartaCorrecao(ANota: TNota; const ACnpjEmitente, ACorrecao: string;
      ASequencia: Integer): TRetornoFiscal;
    function Inutilizar(const ACnpjEmitente: string; AModelo: TModeloNota; ASerie, AAno,
      ANumeroInicial, ANumeroFinal: Integer; const AJustificativa: string): TRetornoFiscal;
    procedure ImprimirDanfe(const AXml: string; AModelo: TModeloNota);
    function GerarPdfDanfe(const AXml: string; AModelo: TModeloNota): string;
    procedure EnviarEmail(const AXml: string; AModelo: TModeloNota; const ADestinatario,
      AAssunto, AMensagem: string);
  end;

  TFakeArquivoXml = class(TInterfacedObject, IArquivoXml)
  public
    Arquivos: TDictionary<string, string>;
    constructor Create;
    destructor Destroy; override;
    function Salvar(const ACnpj, ANome, AConteudo: string; AData: TDateTime): string;
    function Ler(const ACaminho: string): string;
  end;

  TFakeLog = class(TInterfacedObject, ILog)
  public
    Linhas: TStringList;
    constructor Create;
    destructor Destroy; override;
    procedure Registrar(ANivel: TNivelLog; const AMensagem: string);
    procedure Info(const AMensagem: string);
    procedure Erro(const AMensagem: string);
    procedure Fiscal(const AMensagem: string);
    function ContemFiscal(const ATrecho: string): Boolean;
  end;

const
  CHAVE_TESTE = '35261111222333000181550010000000011000000010';

implementation

{ TFakeNotaRepository }

constructor TFakeNotaRepository.Create;
begin
  inherited;
  ProximoId := 1;
  Notas := TObjectList<TNota>.Create;
  Pendencias := TDictionary<Integer, Boolean>.Create;
end;

destructor TFakeNotaRepository.Destroy;
begin
  Pendencias.Free;
  Notas.Free;
  inherited;
end;

function CopiarCabecalho(ANota: TNota): TNota;
begin
  Result := TNota.Create;
  Result.Id := ANota.Id;
  Result.Modelo := ANota.Modelo;
  Result.Serie := ANota.Serie;
  Result.Numero := ANota.Numero;
  Result.DataEmissao := ANota.DataEmissao;
  Result.Status := ANota.Status;
  Result.Chave := ANota.Chave;
  Result.PedidoApiId := ANota.PedidoApiId;
  Result.FaturamentoPendente := ANota.FaturamentoPendente;
end;

procedure TFakeNotaRepository.Guardar(ANota: TNota; APendente: Boolean);
begin
  Notas.Add(CopiarCabecalho(ANota));
  Pendencias.AddOrSetValue(ANota.Id, APendente);
end;

function TFakeNotaRepository.Pendente(ANotaId: Integer): Boolean;
begin
  Result := Pendencias.ContainsKey(ANotaId) and Pendencias[ANotaId];
end;

procedure TFakeNotaRepository.MarcarFaturamentoPendente(ANotaId: Integer; APendente: Boolean);
begin
  Pendencias.AddOrSetValue(ANotaId, APendente);
end;

function TFakeNotaRepository.ListarFaturamentoPendente: TObjectList<TNota>;
var
  LNota: TNota;
begin
  Result := TObjectList<TNota>.Create;
  for LNota in Notas do
    if Pendente(LNota.Id) and (LNota.PedidoApiId > 0) then
    begin
      Result.Add(CopiarCabecalho(LNota));
      Result.Last.FaturamentoPendente := True;
    end;
end;

procedure TFakeNotaRepository.Salvar(ANota: TNota);
begin
  if ANota.Id = 0 then
  begin
    ANota.Id := ProximoId;
    Inc(ProximoId);
  end;
  Inc(Salvamentos);
end;

procedure TFakeNotaRepository.AtualizarSituacao(ANota: TNota);
begin
  Inc(Atualizacoes);
  UltimoStatus := ANota.Status;
end;

function TFakeNotaRepository.Obter(AId: Integer): TNota;
begin
  if Assigned(CriarNotaObter) then
    Result := CriarNotaObter()
  else
    Result := nil;
end;

function TFakeNotaRepository.Listar(const AFiltro: TFiltroNota): TObjectList<TNota>;
begin
  Result := TObjectList<TNota>.Create;
end;

function TFakeNotaRepository.ObterFaturadaDoPedido(APedidoApiId: Integer): TNota;
begin
  if (PedidoFaturado = 0) or (APedidoApiId <> PedidoFaturado) then
    Exit(nil);
  Result := TNota.Create;
  Result.Id := 99;
  Result.Numero := NumeroNotaFaturada;
  Result.Status := TStatusNota.Autorizada;
  Result.PedidoApiId := APedidoApiId;
end;

{ TFakeEmitenteRepository }

constructor TFakeEmitenteRepository.Create;
begin
  inherited;
  ProximoNumero := 1;
  Regime := TRegimeTributario.SimplesNacional;
end;

function TFakeEmitenteRepository.Obter: TEmitente;
begin
  Result := TEmitente.Create;
  Result.Id := 1;
  Result.RazaoSocial := 'EMPRESA TESTE LTDA';
  Result.CNPJ := '11222333000181';
  Result.IE := '111111111111';
  Result.Regime := Regime;
  Result.Endereco.Logradouro := 'RUA TESTE';
  Result.Endereco.Numero := '1';
  Result.Endereco.Bairro := 'CENTRO';
  Result.Endereco.CodigoMunicipio := 3550308;
  Result.Endereco.Municipio := 'SAO PAULO';
  Result.Endereco.UF := 'SP';
  Result.Endereco.CEP := '01001000';
end;

procedure TFakeEmitenteRepository.Salvar(AEmitente: TEmitente);
begin
end;

function TFakeEmitenteRepository.ReservarNumero(AModelo: TModeloNota): Integer;
begin
  Result := ProximoNumero;
  Inc(ProximoNumero);
  Inc(Reservas);
end;

{ TFakeClienteRepository }

function TFakeClienteRepository.Listar(const AFiltro: string): TObjectList<TCliente>;
begin
  Result := TObjectList<TCliente>.Create;
end;

function TFakeClienteRepository.Obter(AId: Integer): TCliente;
begin
  if AId <> 1 then
    Exit(nil);
  Result := TCliente.Create;
  Result.Id := 1;
  Result.Nome := 'CLIENTE TESTE';
  Result.CpfCnpj := '52998224725';
  Result.IndicadorIE := TIndicadorIE.NaoContribuinte;
  Result.Endereco.Logradouro := 'AV TESTE';
  Result.Endereco.Numero := '2';
  Result.Endereco.Bairro := 'CENTRO';
  Result.Endereco.CodigoMunicipio := 3550308;
  Result.Endereco.Municipio := 'SAO PAULO';
  if UF <> '' then
    Result.Endereco.UF := UF
  else
    Result.Endereco.UF := 'SP';
end;

function TFakeClienteRepository.ObterPorDocumento(const ADocumento: string): TCliente;
begin
  if ADocumento = '52998224725' then
    Result := Obter(1)
  else
    Result := nil;
end;

procedure TFakeClienteRepository.Salvar(ACliente: TCliente);
begin
end;

procedure TFakeClienteRepository.Inativar(AId: Integer);
begin
end;

{ TFakeProdutoRepository }

constructor TFakeProdutoRepository.Create;
begin
  inherited;
  CstCsosn := '102';
end;

function TFakeProdutoRepository.Listar(const AFiltro: string): TObjectList<TProduto>;
begin
  Result := TObjectList<TProduto>.Create;
end;

function TFakeProdutoRepository.Obter(AId: Integer): TProduto;
begin
  if not (AId in [1, 2]) then
    Exit(nil);
  Result := TProduto.Create;
  Result.Id := AId;
  Result.Codigo := Format('%.4d', [AId]);
  Result.Descricao := 'PRODUTO ' + IntToStr(AId);
  Result.NCM := '61091000';
  Result.CFOP := '5102';
  Result.Unidade := 'UN';
  Result.CstCsosn := CstCsosn;
  Result.Ativo := AId <> InativoId;
  if AId = 1 then
    Result.Preco := 10.00
  else
    Result.Preco := 33.33;
end;

function TFakeProdutoRepository.ObterPorCodigo(const ACodigo: string): TProduto;
begin
  Result := Obter(StrToIntDef(ACodigo, 0));
end;

procedure TFakeProdutoRepository.Salvar(AProduto: TProduto);
begin
end;

procedure TFakeProdutoRepository.Inativar(AId: Integer);
begin
end;

{ TFakeVinculoRepository }

constructor TFakeVinculoRepository.Create;
begin
  inherited;
  Vinculos := TDictionary<Integer, Integer>.Create;
end;

destructor TFakeVinculoRepository.Destroy;
begin
  Vinculos.Free;
  inherited;
end;

function TFakeVinculoRepository.ProdutoDoEmissor(AApiProdutoId: Integer): Integer;
begin
  if not Vinculos.TryGetValue(AApiProdutoId, Result) then
    Result := 0;
end;

procedure TFakeVinculoRepository.Gravar(AApiProdutoId, AProdutoId: Integer);
begin
  Vinculos.AddOrSetValue(AApiProdutoId, AProdutoId);
end;

{ TFakeFormaPagamentoRepository }

function TFakeFormaPagamentoRepository.Listar(AApenasAtivas: Boolean): TObjectList<TFormaPagamento>;
begin
  Result := TObjectList<TFormaPagamento>.Create;
end;

function TFakeFormaPagamentoRepository.Obter(AId: Integer): TFormaPagamento;
begin
  Result := TFormaPagamento.Create;
  Result.Id := AId;
  if AId = 2 then
  begin
    Result.Descricao := 'Cartão de crédito';
    Result.CodigoSefaz := '03';
  end
  else
  begin
    Result.Descricao := 'Dinheiro';
    Result.CodigoSefaz := '01';
  end;
end;

procedure TFakeFormaPagamentoRepository.Salvar(AForma: TFormaPagamento);
begin
end;

{ TFakeEventoRepository }

constructor TFakeEventoRepository.Create;
begin
  inherited;
  Eventos := TList<TEventoRegistrado>.Create;
  SequenciaCCe := 1;
end;

destructor TFakeEventoRepository.Destroy;
begin
  Eventos.Free;
  inherited;
end;

procedure TFakeEventoRepository.Registrar(AEvento: TEventoFiscal);
var
  LEvento: TEventoRegistrado;
begin
  LEvento.Tipo := AEvento.Tipo;
  LEvento.Sucesso := AEvento.Sucesso;
  LEvento.CStat := AEvento.CStat;
  LEvento.ArquivoXml := AEvento.ArquivoXml;
  Eventos.Add(LEvento);
end;

function TFakeEventoRepository.ListarPorNota(ANotaId: Integer): TObjectList<TEventoFiscal>;
begin
  Result := TObjectList<TEventoFiscal>.Create;
end;

function TFakeEventoRepository.ProximaSequenciaCCe(ANotaId: Integer): Integer;
begin
  Result := SequenciaCCe;
end;

{ TFakeEmissor }

constructor TFakeEmissor.Create;
begin
  inherited;
  // padrão: SEFAZ autoriza
  RetornoTransmissao.CStat := 100;
  RetornoTransmissao.Motivo := 'Autorizado o uso da NF-e';
  RetornoTransmissao.Protocolo := '135260000000001';
  RetornoTransmissao.Chave := CHAVE_TESTE;
  RetornoTransmissao.XmlEnvio := '<NFe/>';
  RetornoTransmissao.XmlRetorno := '<nfeProc/>';

  RetornoContingencia.Chave := CHAVE_TESTE;
  RetornoContingencia.XmlEnvio := '<NFe tpEmis="9"/>';

  RetornoEvento.CStat := 135;
  RetornoEvento.Motivo := 'Evento registrado e vinculado a NF-e';
  RetornoEvento.Protocolo := '135260000000002';
  RetornoEvento.XmlRetorno := '<procEventoNFe/>';
end;

function TFakeEmissor.StatusServico(AModelo: TModeloNota): TRetornoFiscal;
begin
  Result := Default(TRetornoFiscal);
  Result.CStat := 107;
  Result.Motivo := 'Servico em Operacao';
end;

function TFakeEmissor.Transmitir(ANota: TNota; AEmitente: TEmitente; ADestinatario: TCliente;
  AContingencia: Boolean): TRetornoFiscal;
begin
  if AContingencia then
  begin
    GerouContingencia := True;
    Exit(RetornoContingencia);
  end;
  Inc(Transmissoes);
  Result := RetornoTransmissao;
end;

function TFakeEmissor.TransmitirXml(const AXml: string; AModelo: TModeloNota): TRetornoFiscal;
begin
  Inc(Transmissoes);
  Result := RetornoTransmissao;
end;

function TFakeEmissor.Cancelar(ANota: TNota; const ACnpjEmitente, AJustificativa: string): TRetornoFiscal;
begin
  Result := RetornoEvento;
end;

function TFakeEmissor.CartaCorrecao(ANota: TNota; const ACnpjEmitente, ACorrecao: string;
  ASequencia: Integer): TRetornoFiscal;
begin
  Result := RetornoEvento;
end;

function TFakeEmissor.Inutilizar(const ACnpjEmitente: string; AModelo: TModeloNota; ASerie, AAno,
  ANumeroInicial, ANumeroFinal: Integer; const AJustificativa: string): TRetornoFiscal;
begin
  Result := Default(TRetornoFiscal);
  Result.CStat := 102;
  Result.Motivo := 'Inutilizacao de numero homologado';
  Result.XmlRetorno := '<procInutNFe/>';
end;

procedure TFakeEmissor.ImprimirDanfe(const AXml: string; AModelo: TModeloNota);
begin
end;

function TFakeEmissor.GerarPdfDanfe(const AXml: string; AModelo: TModeloNota): string;
begin
  Result := 'danfe.pdf';
end;

procedure TFakeEmissor.EnviarEmail(const AXml: string; AModelo: TModeloNota; const ADestinatario,
  AAssunto, AMensagem: string);
begin
end;

{ TFakeArquivoXml }

constructor TFakeArquivoXml.Create;
begin
  inherited;
  Arquivos := TDictionary<string, string>.Create;
end;

destructor TFakeArquivoXml.Destroy;
begin
  Arquivos.Free;
  inherited;
end;

function TFakeArquivoXml.Salvar(const ACnpj, ANome, AConteudo: string; AData: TDateTime): string;
begin
  Result := ACnpj + '\' + ANome + '.xml';
  Arquivos.AddOrSetValue(Result, AConteudo);
end;

function TFakeArquivoXml.Ler(const ACaminho: string): string;
begin
  if not Arquivos.TryGetValue(ACaminho, Result) then
    Result := '<NFe/>';
end;

{ TFakeLog }

constructor TFakeLog.Create;
begin
  inherited;
  Linhas := TStringList.Create;
end;

destructor TFakeLog.Destroy;
begin
  Linhas.Free;
  inherited;
end;

procedure TFakeLog.Registrar(ANivel: TNivelLog; const AMensagem: string);
const
  NIVEIS: array[TNivelLog] of string = ('INFO', 'AVISO', 'ERRO', 'FISCAL');
begin
  Linhas.Add(NIVEIS[ANivel] + ' ' + AMensagem);
end;

procedure TFakeLog.Info(const AMensagem: string);
begin
  Registrar(TNivelLog.Info, AMensagem);
end;

procedure TFakeLog.Erro(const AMensagem: string);
begin
  Registrar(TNivelLog.Erro, AMensagem);
end;

procedure TFakeLog.Fiscal(const AMensagem: string);
begin
  Registrar(TNivelLog.Fiscal, AMensagem);
end;

function TFakeLog.ContemFiscal(const ATrecho: string): Boolean;
var
  LLinha: string;
begin
  for LLinha in Linhas do
    if LLinha.StartsWith('FISCAL') and LLinha.Contains(ATrecho) then
      Exit(True);
  Result := False;
end;

end.
