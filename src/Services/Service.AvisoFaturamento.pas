unit Service.AvisoFaturamento;

{
  Avisa a delphi-horse-api quando a NF-e de um pedido é autorizada ou cancelada,
  para o pedido aparecer como faturado (no cliente VCL e no app Força de Vendas).

  O aviso nunca atrapalha a operação fiscal:
  - API fora do ar → a nota fica com FATURAMENTO_PENDENTE e o aviso é reenviado
    depois (ao abrir o sistema e a tela de pedidos da API);
  - API recusa (pedido cancelado lá, inexistente...) → só log: repetir não resolve.
  O que reenviar sai da situação atual da nota, então uma nota autorizada com aviso
  pendente e cancelada em seguida manda só o cancelamento.
}

interface

uses
  System.SysUtils, Model.Nota, Infra.ApiPedidos, Infra.Log, Repository.Nota;

type
  {$SCOPEDENUMS ON}
  TResultadoAviso = (Aceito, Recusado, Indisponivel);
  {$SCOPEDENUMS OFF}

  IAvisoFaturamento = interface
    ['{6D1F3A5B-7C9E-4B2D-8F4A-0E2C4A6B8D13}']
    /// Nunca levanta exceção de API: sem API → pendência; recusa → log.
    procedure NotaAutorizada(ANota: TNota);
    procedure NotaCancelada(ANota: TNota);
    /// Reenvia as pendentes e para na primeira API indisponível. Devolve quantas a API aceitou.
    function ReenviarPendentes: Integer;
  end;

  TAvisoFaturamentoService = class(TInterfacedObject, IAvisoFaturamento)
  private
    FApi: IPedidoApi;
    FNotaRepo: INotaRepository;
    FLog: ILog;
    function Avisar(ANota: TNota; ACancelada: Boolean): TResultadoAviso;
  public
    constructor Create(AApi: IPedidoApi; ANotaRepo: INotaRepository; ALog: ILog);
    procedure NotaAutorizada(ANota: TNota);
    procedure NotaCancelada(ANota: TNota);
    function ReenviarPendentes: Integer;
  end;

implementation

uses
  System.Generics.Collections, Model.Tipos;

constructor TAvisoFaturamentoService.Create(AApi: IPedidoApi; ANotaRepo: INotaRepository; ALog: ILog);
begin
  inherited Create;
  FApi := AApi;
  FNotaRepo := ANotaRepo;
  FLog := ALog;
end;

function TAvisoFaturamentoService.Avisar(ANota: TNota; ACancelada: Boolean): TResultadoAviso;
const
  ACAO: array[Boolean] of string = ('autorizada', 'cancelada');
begin
  Result := TResultadoAviso.Aceito;
  try
    if ACancelada then
      FApi.RemoverFaturamento(ANota.PedidoApiId)
    else
      // a nota não guarda a hora do protocolo; a emissão é gravada no envio, segundos antes
      FApi.Faturar(ANota.PedidoApiId, ANota.Numero, ANota.Serie, ANota.Chave, ANota.DataEmissao);

    if ANota.FaturamentoPendente then
      FNotaRepo.MarcarFaturamentoPendente(ANota.Id, False);
    FLog.Info(Format('Pedido %d avisado na API: NF-e %d %s', [ANota.PedidoApiId, ANota.Numero,
      ACAO[ACancelada]]));
  except
    on E: EApiIndisponivel do
    begin
      if not ANota.FaturamentoPendente then
        FNotaRepo.MarcarFaturamentoPendente(ANota.Id, True);
      FLog.Erro(Format('Aviso do pedido %d (NF-e %d %s) ficou pendente: %s',
        [ANota.PedidoApiId, ANota.Numero, ACAO[ACancelada], E.Message]));
      Result := TResultadoAviso.Indisponivel;
    end;
    on E: EApiPedidos do
    begin
      if ANota.FaturamentoPendente then
        FNotaRepo.MarcarFaturamentoPendente(ANota.Id, False);
      FLog.Erro(Format('A API recusou o aviso do pedido %d (NF-e %d %s): %s',
        [ANota.PedidoApiId, ANota.Numero, ACAO[ACancelada], E.Message]));
      Result := TResultadoAviso.Recusado;
    end;
  end;
end;

procedure TAvisoFaturamentoService.NotaAutorizada(ANota: TNota);
begin
  if ANota.PedidoApiId > 0 then
    Avisar(ANota, False);
end;

procedure TAvisoFaturamentoService.NotaCancelada(ANota: TNota);
begin
  if ANota.PedidoApiId > 0 then
    Avisar(ANota, True);
end;

function TAvisoFaturamentoService.ReenviarPendentes: Integer;
var
  LNotas: TObjectList<TNota>;
  LNota: TNota;
  LResultado: TResultadoAviso;
begin
  Result := 0;
  LNotas := FNotaRepo.ListarFaturamentoPendente;
  try
    for LNota in LNotas do
    begin
      if not (LNota.Status in [TStatusNota.Autorizada, TStatusNota.Cancelada]) then
      begin
        // não deveria acontecer; não há o que avisar
        FNotaRepo.MarcarFaturamentoPendente(LNota.Id, False);
        Continue;
      end;
      LResultado := Avisar(LNota, LNota.Status = TStatusNota.Cancelada);
      if LResultado = TResultadoAviso.Indisponivel then
        Break; // API fora: as outras esperariam o mesmo timeout
      if LResultado = TResultadoAviso.Aceito then
        Inc(Result);
    end;
  finally
    LNotas.Free;
  end;
end;

end.
