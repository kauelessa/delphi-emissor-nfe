unit View.PedidoApi;

// Lista os pedidos da delphi-horse-api para escolher qual faturar.

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, System.UITypes, Vcl.Menus, Vcl.StdCtrls, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, dxLayoutContainer, dxLayoutControl,
  dxLayoutcxEditAdapters, dxLayoutControlAdapters, cxButtons, cxLabel, cxStyles, cxCustomData,
  cxFilter, cxData, cxDataStorage, cxNavigator, dxDateRanges, dxScrollbarAnnotations,
  cxGridCustomTableView, cxGridTableView, cxGridCustomView, cxClasses, cxGridLevel, cxGrid,
  cxTextEdit, cxCurrencyEdit, dxCore, dxUIAClasses, Model.PedidoApi;

type
  TfrmPedidoApi = class(TForm)
    lcPedidos: TdxLayoutControl;
    lcPedidosGroup_Root: TdxLayoutGroup;
    lblInstrucao: TcxLabel;
    grdPedidos: TcxGrid;
    tvPedidos: TcxGridTableView;
    tvPedidosNumero: TcxGridColumn;
    tvPedidosData: TcxGridColumn;
    tvPedidosCliente: TcxGridColumn;
    tvPedidosTotal: TcxGridColumn;
    tvPedidosStatus: TcxGridColumn;
    tvPedidosNota: TcxGridColumn;
    lvPedidos: TcxGridLevel;
    lblMotivo: TcxLabel;
    btnAnterior: TcxButton;
    lblPagina: TcxLabel;
    btnProxima: TcxButton;
    btnEscolher: TcxButton;
    btnCancelar: TcxButton;
    liInstrucao: TdxLayoutItem;
    liPedidos: TdxLayoutItem;
    liMotivo: TdxLayoutItem;
    grpRodape: TdxLayoutGroup;
    liAnterior: TdxLayoutItem;
    liPagina: TdxLayoutItem;
    liProxima: TdxLayoutItem;
    liEscolher: TdxLayoutItem;
    liCancelar: TdxLayoutItem;
    procedure FormDestroy(Sender: TObject);
    procedure btnAnteriorClick(Sender: TObject);
    procedure btnProximaClick(Sender: TObject);
    procedure btnEscolherClick(Sender: TObject);
    procedure tvPedidosDblClick(Sender: TObject);
    procedure tvPedidosFocusedRecordChanged(Sender: TcxCustomGridTableView;
      APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord;
      ANewItemRecordFocusingChanged: Boolean);
  private
    FPagina: TPaginaPedidosApi;
    FIdEscolhido: Integer;
    procedure Carregar(APagina: Integer);
    function PedidoSelecionado: TPedidoApi;
    procedure AtualizarSelecao;
  public
    /// Id do pedido escolhido; 0 = cancelou.
    class function Escolher: Integer;
  end;

implementation

{$R *.dfm}

uses
  Controller.PedidoApi;

class function TfrmPedidoApi.Escolher: Integer;
var
  LForm: TfrmPedidoApi;
begin
  LForm := TfrmPedidoApi.Create(nil);
  try
    // aproveita a ida à API para mandar avisos de faturamento que ficaram pendentes
    TPedidoApiController.ReenviarAvisosPendentes;
    // carrega antes de mostrar: com a API fora do ar o erro aparece sem abrir uma tela vazia
    LForm.Carregar(1);
    if LForm.ShowModal = mrOk then
      Result := LForm.FIdEscolhido
    else
      Result := 0;
  finally
    LForm.Free;
  end;
end;

procedure TfrmPedidoApi.FormDestroy(Sender: TObject);
begin
  FPagina.Free;
end;

procedure TfrmPedidoApi.Carregar(APagina: Integer);
var
  LNova: TPaginaPedidosApi;
  LPedido: TPedidoApi;
  I: Integer;
begin
  Screen.Cursor := crHourGlass;
  try
    LNova := TPedidoApiController.Listar(APagina);
  finally
    Screen.Cursor := crDefault;
  end;
  FPagina.Free;
  FPagina := LNova;

  tvPedidos.BeginUpdate;
  try
    tvPedidos.DataController.RecordCount := FPagina.Pedidos.Count;
    for I := 0 to FPagina.Pedidos.Count - 1 do
    begin
      LPedido := FPagina.Pedidos[I];
      tvPedidos.DataController.Values[I, tvPedidosNumero.Index] := LPedido.Id;
      tvPedidos.DataController.Values[I, tvPedidosData.Index] := FormatDateTime('dd/mm/yyyy hh:nn', LPedido.Data);
      tvPedidos.DataController.Values[I, tvPedidosCliente.Index] := LPedido.ClienteNome;
      tvPedidos.DataController.Values[I, tvPedidosTotal.Index] := LPedido.ValorTotal;
      if LPedido.Status = TStatusPedidoApi.Cancelado then
        tvPedidos.DataController.Values[I, tvPedidosStatus.Index] := 'Cancelado'
      else
        tvPedidos.DataController.Values[I, tvPedidosStatus.Index] := 'Aberto';
      if LPedido.NotaNumero > 0 then
        tvPedidos.DataController.Values[I, tvPedidosNota.Index] := 'NF-e ' + LPedido.NotaNumero.ToString
      else
        tvPedidos.DataController.Values[I, tvPedidosNota.Index] := '';
    end;
  finally
    tvPedidos.EndUpdate;
  end;
  if FPagina.Pedidos.Count > 0 then
    tvPedidos.DataController.FocusedRecordIndex := 0;

  lblPagina.Caption := Format('Página %d de %d  (%d pedidos)',
    [FPagina.Pagina, FPagina.TotalPaginas(TPedidoApiController.POR_PAGINA), FPagina.Total]);
  btnAnterior.Enabled := FPagina.Pagina > 1;
  btnProxima.Enabled := FPagina.Pagina < FPagina.TotalPaginas(TPedidoApiController.POR_PAGINA);
  AtualizarSelecao;
end;

function TfrmPedidoApi.PedidoSelecionado: TPedidoApi;
var
  LIndice: Integer;
begin
  // a ordenação do grid está desligada: a linha corresponde à posição na página
  LIndice := tvPedidos.DataController.FocusedRecordIndex;
  if (FPagina = nil) or (LIndice < 0) or (LIndice >= FPagina.Pedidos.Count) then
    Exit(nil);
  Result := FPagina.Pedidos[LIndice];
end;

procedure TfrmPedidoApi.AtualizarSelecao;
var
  LPedido: TPedidoApi;
begin
  LPedido := PedidoSelecionado;
  if LPedido = nil then
    lblMotivo.Caption := ''
  else if LPedido.Status = TStatusPedidoApi.Cancelado then
    lblMotivo.Caption := 'Pedido cancelado na API não pode ser faturado.'
  else if LPedido.NotaNumero > 0 then
    lblMotivo.Caption := Format('Pedido já faturado na NF-e %d.', [LPedido.NotaNumero])
  else
    lblMotivo.Caption := '';
  btnEscolher.Enabled := (LPedido <> nil) and (lblMotivo.Caption = '');
end;

procedure TfrmPedidoApi.tvPedidosFocusedRecordChanged(Sender: TcxCustomGridTableView;
  APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord; ANewItemRecordFocusingChanged: Boolean);
begin
  AtualizarSelecao;
end;

procedure TfrmPedidoApi.tvPedidosDblClick(Sender: TObject);
begin
  if btnEscolher.Enabled then
    btnEscolher.Click;
end;

procedure TfrmPedidoApi.btnAnteriorClick(Sender: TObject);
begin
  Carregar(FPagina.Pagina - 1);
end;

procedure TfrmPedidoApi.btnProximaClick(Sender: TObject);
begin
  Carregar(FPagina.Pagina + 1);
end;

procedure TfrmPedidoApi.btnEscolherClick(Sender: TObject);
begin
  FIdEscolhido := PedidoSelecionado.Id;
  ModalResult := mrOk;
end;

end.
