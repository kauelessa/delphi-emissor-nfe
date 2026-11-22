unit Test.AvisoFaturamento;

interface

uses
  System.SysUtils, System.Generics.Collections, DUnitX.TestFramework, Model.Tipos, Model.Nota,
  Model.PedidoApi, Infra.ApiPedidos, Service.AvisoFaturamento, Test.Fakes;

type
  TAvisoChamada = record
    Metodo: string;
    PedidoId, Numero, Serie: Integer;
    Chave: string;
    AutorizadaEm: TDateTime;
  end;

  // grava os avisos; Falhas[i] (se houver) é a exceção da i-ésima chamada
  TApiAvisoFake = class(TInterfacedObject, IPedidoApi)
  private
    procedure Chamou(const AChamada: TAvisoChamada);
  public
    Chamadas: TList<TAvisoChamada>;
    Falhas: TList<ExceptClass>;
    SempreIndisponivel: Boolean;
    constructor Create;
    destructor Destroy; override;
    function Listar(APagina, ALimite: Integer): TPaginaPedidosApi;
    function Obter(AId: Integer): TPedidoApi;
    function ObterCliente(AId: Integer): TClienteApi;
    procedure Faturar(APedidoId, ANumero, ASerie: Integer; const AChave: string; AAutorizadaEm: TDateTime);
    procedure RemoverFaturamento(APedidoId: Integer);
  end;

  [TestFixture]
  TTestAvisoFaturamento = class
  private
    FApi: TApiAvisoFake;
    FApiRef: IPedidoApi;
    FNotas: TFakeNotaRepository;
    FNotasRef: IInterface;
    FLog: TFakeLog;
    FLogRef: IInterface;
    FAviso: IAvisoFaturamento;
    function NovaNota(AId, APedido: Integer; AStatus: TStatusNota): TNota;
    function LogTem(const ATrecho: string): Boolean;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure NotaAutorizada_SemPedido_NaoChamaApi;
    [Test]
    procedure NotaAutorizada_ComPedido_EnviaDadosDaNota;
    [Test]
    procedure NotaAutorizada_ApiFora_MarcaPendente;
    [Test]
    procedure NotaAutorizada_ApiRecusa_SoRegistraLog;
    [Test]
    procedure NotaCancelada_ComPedido_RemoveFaturamento;
    [Test]
    procedure NotaCancelada_ComPendenciaAnterior_LimpaPendencia;
    [Test]
    procedure Reenviar_AutorizadaPendente_FaturaELimpa;
    [Test]
    procedure Reenviar_CanceladaPendente_RemoveFaturamento;
    [Test]
    procedure Reenviar_ApiFora_ParaNaPrimeira;
    [Test]
    procedure Reenviar_ApiRecusa_LimpaESegue;
  end;

implementation

uses
  System.DateUtils;

const
  CHAVE_44 = '35261111222333000181550010000001231000001230';

{ TApiAvisoFake }

constructor TApiAvisoFake.Create;
begin
  inherited;
  Chamadas := TList<TAvisoChamada>.Create;
  Falhas := TList<ExceptClass>.Create;
end;

destructor TApiAvisoFake.Destroy;
begin
  Falhas.Free;
  Chamadas.Free;
  inherited;
end;

procedure TApiAvisoFake.Chamou(const AChamada: TAvisoChamada);
var
  LFalha: ExceptClass;
begin
  Chamadas.Add(AChamada);
  if SempreIndisponivel then
    raise EApiIndisponivel.Create('Não foi possível conectar à API em http://localhost:9000.');
  if Chamadas.Count <= Falhas.Count then
  begin
    LFalha := Falhas[Chamadas.Count - 1];
    if LFalha <> nil then
      raise LFalha.Create('Pedido cancelado não pode ser faturado.');
  end;
end;

function TApiAvisoFake.Listar(APagina, ALimite: Integer): TPaginaPedidosApi;
begin
  Result := TPaginaPedidosApi.Create;
end;

function TApiAvisoFake.Obter(AId: Integer): TPedidoApi;
begin
  Result := nil;
end;

function TApiAvisoFake.ObterCliente(AId: Integer): TClienteApi;
begin
  Result := nil;
end;

procedure TApiAvisoFake.Faturar(APedidoId, ANumero, ASerie: Integer; const AChave: string;
  AAutorizadaEm: TDateTime);
var
  LChamada: TAvisoChamada;
begin
  LChamada := Default(TAvisoChamada);
  LChamada.Metodo := 'PATCH';
  LChamada.PedidoId := APedidoId;
  LChamada.Numero := ANumero;
  LChamada.Serie := ASerie;
  LChamada.Chave := AChave;
  LChamada.AutorizadaEm := AAutorizadaEm;
  Chamou(LChamada);
end;

procedure TApiAvisoFake.RemoverFaturamento(APedidoId: Integer);
var
  LChamada: TAvisoChamada;
begin
  LChamada := Default(TAvisoChamada);
  LChamada.Metodo := 'DELETE';
  LChamada.PedidoId := APedidoId;
  Chamou(LChamada);
end;

{ TTestAvisoFaturamento }

procedure TTestAvisoFaturamento.Setup;
begin
  FApi := TApiAvisoFake.Create;
  FApiRef := FApi;
  FNotas := TFakeNotaRepository.Create;
  FNotasRef := FNotas;
  FLog := TFakeLog.Create;
  FLogRef := FLog;
  FAviso := TAvisoFaturamentoService.Create(FApi, FNotas, FLog);
end;

procedure TTestAvisoFaturamento.TearDown;
begin
  FAviso := nil;
  FApiRef := nil;
  FNotasRef := nil;
  FLogRef := nil;
end;

function TTestAvisoFaturamento.NovaNota(AId, APedido: Integer; AStatus: TStatusNota): TNota;
begin
  Result := TNota.Create;
  Result.Id := AId;
  Result.Modelo := TModeloNota.NFe;
  Result.Numero := 120 + AId;
  Result.Serie := 1;
  Result.Chave := CHAVE_44;
  Result.DataEmissao := EncodeDateTime(2026, 11, 22, 14, 5, 0, 0);
  Result.Status := AStatus;
  Result.PedidoApiId := APedido;
end;

function TTestAvisoFaturamento.LogTem(const ATrecho: string): Boolean;
begin
  Result := FLog.Linhas.Text.Contains(ATrecho);
end;

procedure TTestAvisoFaturamento.NotaAutorizada_SemPedido_NaoChamaApi;
var
  LNota: TNota;
begin
  LNota := NovaNota(1, 0, TStatusNota.Autorizada);
  try
    FAviso.NotaAutorizada(LNota);
    Assert.AreEqual(0, FApi.Chamadas.Count);
  finally
    LNota.Free;
  end;
end;

procedure TTestAvisoFaturamento.NotaAutorizada_ComPedido_EnviaDadosDaNota;
var
  LNota: TNota;
begin
  LNota := NovaNota(3, 12, TStatusNota.Autorizada);
  try
    FAviso.NotaAutorizada(LNota);
    Assert.AreEqual(1, FApi.Chamadas.Count);
    Assert.AreEqual('PATCH', FApi.Chamadas[0].Metodo);
    Assert.AreEqual(12, FApi.Chamadas[0].PedidoId);
    Assert.AreEqual(123, FApi.Chamadas[0].Numero);
    Assert.AreEqual(1, FApi.Chamadas[0].Serie);
    Assert.AreEqual(CHAVE_44, FApi.Chamadas[0].Chave);
    Assert.AreEqual(LNota.DataEmissao, FApi.Chamadas[0].AutorizadaEm);
    Assert.IsFalse(FNotas.Pendente(3));
  finally
    LNota.Free;
  end;
end;

procedure TTestAvisoFaturamento.NotaAutorizada_ApiFora_MarcaPendente;
var
  LNota: TNota;
begin
  FApi.SempreIndisponivel := True;
  LNota := NovaNota(3, 12, TStatusNota.Autorizada);
  try
    FNotas.Guardar(LNota);
    FAviso.NotaAutorizada(LNota); // não pode levantar
    Assert.IsTrue(FNotas.Pendente(3));
    Assert.IsTrue(LogTem('ERRO'));
    Assert.IsTrue(LogTem('Não foi possível conectar'));
  finally
    LNota.Free;
  end;
end;

procedure TTestAvisoFaturamento.NotaAutorizada_ApiRecusa_SoRegistraLog;
var
  LNota: TNota;
begin
  FApi.Falhas.Add(EApiPedidoRecusado);
  LNota := NovaNota(3, 12, TStatusNota.Autorizada);
  try
    FNotas.Guardar(LNota);
    FAviso.NotaAutorizada(LNota);
    Assert.IsFalse(FNotas.Pendente(3));
    Assert.IsTrue(LogTem('Pedido cancelado não pode ser faturado.'));
  finally
    LNota.Free;
  end;
end;

procedure TTestAvisoFaturamento.NotaCancelada_ComPedido_RemoveFaturamento;
var
  LNota: TNota;
begin
  LNota := NovaNota(3, 12, TStatusNota.Cancelada);
  try
    FAviso.NotaCancelada(LNota);
    Assert.AreEqual(1, FApi.Chamadas.Count);
    Assert.AreEqual('DELETE', FApi.Chamadas[0].Metodo);
    Assert.AreEqual(12, FApi.Chamadas[0].PedidoId);
  finally
    LNota.Free;
  end;
end;

procedure TTestAvisoFaturamento.NotaCancelada_ComPendenciaAnterior_LimpaPendencia;
var
  LNota: TNota;
begin
  // o aviso da autorização não chegou; o do cancelamento chega e resolve os dois
  LNota := NovaNota(3, 12, TStatusNota.Cancelada);
  try
    LNota.FaturamentoPendente := True;
    FNotas.Guardar(LNota, True);
    FAviso.NotaCancelada(LNota);
    Assert.IsFalse(FNotas.Pendente(3));
  finally
    LNota.Free;
  end;
end;

procedure TTestAvisoFaturamento.Reenviar_AutorizadaPendente_FaturaELimpa;
var
  LNota: TNota;
begin
  LNota := NovaNota(3, 12, TStatusNota.Autorizada);
  try
    FNotas.Guardar(LNota, True);
  finally
    LNota.Free;
  end;
  Assert.AreEqual(1, FAviso.ReenviarPendentes);
  Assert.AreEqual('PATCH', FApi.Chamadas[0].Metodo);
  Assert.AreEqual(123, FApi.Chamadas[0].Numero);
  Assert.IsFalse(FNotas.Pendente(3));
end;

procedure TTestAvisoFaturamento.Reenviar_CanceladaPendente_RemoveFaturamento;
var
  LNota: TNota;
begin
  // autorizada com aviso pendente e cancelada antes do reenvio: vale a situação atual
  LNota := NovaNota(3, 12, TStatusNota.Cancelada);
  try
    FNotas.Guardar(LNota, True);
  finally
    LNota.Free;
  end;
  Assert.AreEqual(1, FAviso.ReenviarPendentes);
  Assert.AreEqual(1, FApi.Chamadas.Count);
  Assert.AreEqual('DELETE', FApi.Chamadas[0].Metodo);
  Assert.IsFalse(FNotas.Pendente(3));
end;

procedure TTestAvisoFaturamento.Reenviar_ApiFora_ParaNaPrimeira;
var
  I: Integer;
  LNota: TNota;
begin
  FApi.SempreIndisponivel := True;
  for I := 1 to 2 do
  begin
    LNota := NovaNota(I, 10 + I, TStatusNota.Autorizada);
    try
      FNotas.Guardar(LNota, True);
    finally
      LNota.Free;
    end;
  end;
  Assert.AreEqual(0, FAviso.ReenviarPendentes);
  Assert.AreEqual(1, FApi.Chamadas.Count);
  Assert.IsTrue(FNotas.Pendente(1));
  Assert.IsTrue(FNotas.Pendente(2));
end;

procedure TTestAvisoFaturamento.Reenviar_ApiRecusa_LimpaESegue;
var
  I: Integer;
  LNota: TNota;
begin
  FApi.Falhas.Add(EApiPedidoRecusado);
  FApi.Falhas.Add(nil);
  for I := 1 to 2 do
  begin
    LNota := NovaNota(I, 10 + I, TStatusNota.Autorizada);
    try
      FNotas.Guardar(LNota, True);
    finally
      LNota.Free;
    end;
  end;
  Assert.AreEqual(1, FAviso.ReenviarPendentes);
  Assert.AreEqual(2, FApi.Chamadas.Count);
  Assert.IsFalse(FNotas.Pendente(1));
  Assert.IsFalse(FNotas.Pendente(2));
end;

initialization
  TDUnitX.RegisterTestFixture(TTestAvisoFaturamento);

end.
