unit View.Nota;

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, System.UITypes, Vcl.Menus, Vcl.StdCtrls, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, dxLayoutContainer, dxLayoutControl,
  dxLayoutcxEditAdapters, dxLayoutControlAdapters, cxButtons, cxLabel, cxTextEdit, cxMaskEdit,
  cxDropDownEdit, cxCurrencyEdit, cxStyles, cxCustomData, cxFilter, cxData, cxDataStorage,
  cxNavigator, dxDateRanges, dxScrollbarAnnotations, cxGridCustomTableView, cxGridTableView,
  cxGridCustomView, cxClasses, cxGridLevel, cxGrid, dxCore, dxUIAClasses, Model.Tipos,
  Controller.Nota;

type
  TfrmNota = class(TForm)
    lcNota: TdxLayoutControl;
    lcNotaGroup_Root: TdxLayoutGroup;
    cbCliente: TcxComboBox;
    edtCpfConsumidor: TcxTextEdit;
    edtObservacao: TcxTextEdit;
    cbProduto: TcxComboBox;
    edtQuantidade: TcxCurrencyEdit;
    btnAdicionarItem: TcxButton;
    btnRemoverItem: TcxButton;
    btnImportarPedido: TcxButton;
    grdItens: TcxGrid;
    tvItens: TcxGridTableView;
    tvItensNumero: TcxGridColumn;
    tvItensCodigo: TcxGridColumn;
    tvItensDescricao: TcxGridColumn;
    tvItensQuantidade: TcxGridColumn;
    tvItensUnitario: TcxGridColumn;
    tvItensDesconto: TcxGridColumn;
    tvItensTotal: TcxGridColumn;
    lvItens: TcxGridLevel;
    cbFormaPagamento: TcxComboBox;
    edtValorPagamento: TcxCurrencyEdit;
    btnAdicionarPagamento: TcxButton;
    btnRemoverPagamento: TcxButton;
    grdPagamentos: TcxGrid;
    tvPagamentos: TcxGridTableView;
    tvPagamentosForma: TcxGridColumn;
    tvPagamentosValor: TcxGridColumn;
    lvPagamentos: TcxGridLevel;
    edtDesconto: TcxCurrencyEdit;
    btnAplicarDesconto: TcxButton;
    lblProdutos: TcxLabel;
    lblDesconto: TcxLabel;
    lblTotal: TcxLabel;
    lblPago: TcxLabel;
    lblTroco: TcxLabel;
    btnNovaNota: TcxButton;
    btnEmitir: TcxButton;
    btnFechar: TcxButton;
    grpCabecalho: TdxLayoutGroup;
    grpCabecalho1: TdxLayoutGroup;
    liCliente: TdxLayoutItem;
    liCpfConsumidor: TdxLayoutItem;
    liObservacao: TdxLayoutItem;
    grpItens: TdxLayoutGroup;
    grpItens1: TdxLayoutGroup;
    liProduto: TdxLayoutItem;
    liQuantidade: TdxLayoutItem;
    liAdicionarItem: TdxLayoutItem;
    liRemoverItem: TdxLayoutItem;
    liImportarPedido: TdxLayoutItem;
    liItens: TdxLayoutItem;
    grpRodape: TdxLayoutGroup;
    grpPagamento: TdxLayoutGroup;
    grpPagamento1: TdxLayoutGroup;
    liFormaPagamento: TdxLayoutItem;
    liValorPagamento: TdxLayoutItem;
    liAdicionarPagamento: TdxLayoutItem;
    liRemoverPagamento: TdxLayoutItem;
    liPagamentos: TdxLayoutItem;
    grpTotais: TdxLayoutGroup;
    grpDesconto: TdxLayoutGroup;
    liDesconto: TdxLayoutItem;
    liAplicarDesconto: TdxLayoutItem;
    liProdutos: TdxLayoutItem;
    liDescontoTotal: TdxLayoutItem;
    liTotal: TdxLayoutItem;
    liPago: TdxLayoutItem;
    liTroco: TdxLayoutItem;
    grpAcoes: TdxLayoutGroup;
    liNovaNota: TdxLayoutItem;
    liEmitir: TdxLayoutItem;
    liFechar: TdxLayoutItem;
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure cbClientePropertiesChange(Sender: TObject);
    procedure edtQuantidadeKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btnAdicionarItemClick(Sender: TObject);
    procedure btnRemoverItemClick(Sender: TObject);
    procedure btnImportarPedidoClick(Sender: TObject);
    procedure btnAplicarDescontoClick(Sender: TObject);
    procedure btnAdicionarPagamentoClick(Sender: TObject);
    procedure btnRemoverPagamentoClick(Sender: TObject);
    procedure btnNovaNotaClick(Sender: TObject);
    procedure btnEmitirClick(Sender: TObject);
  private
    FController: TNotaController;
    FModelo: TModeloNota;
    FIdsClientes: TArray<Integer>;
    FIdsProdutos: TArray<Integer>;
    FIdsFormas: TArray<Integer>;
    procedure Iniciar(AModelo: TModeloNota);
    procedure CarregarListas;
    procedure AtualizarTela;
    procedure LimparTela;
    procedure SelecionarCliente(AClienteId: Integer);
  public
    class procedure Exibir(AModelo: TModeloNota);
  end;

implementation

{$R *.dfm}

uses
  System.Generics.Collections, Model.Nota, Model.ItemNota, Model.Pagamento, Model.Cliente,
  Model.Produto, Model.FormaPagamento, Model.PedidoApi, Infra.Documento, View.PedidoApi,
  View.VinculoProduto, View.Cliente;

const
  FMT_VALOR = '#,##0.00';

class procedure TfrmNota.Exibir(AModelo: TModeloNota);
var
  LForm: TfrmNota;
begin
  LForm := TfrmNota.Create(nil);
  try
    LForm.Iniciar(AModelo);
    LForm.ShowModal;
  finally
    LForm.Free;
  end;
end;

procedure TfrmNota.Iniciar(AModelo: TModeloNota);
begin
  FModelo := AModelo;
  FController := TNotaController.Create(AModelo);
  Caption := 'Emissão de ' + AModelo.Descricao;
  // CPF na nota só existe na NFC-e; na NF-e o destinatário é obrigatório
  liCpfConsumidor.Visible := AModelo = TModeloNota.NFCe;
  // pedido da API vira NF-e (venda com destinatário identificado)
  liImportarPedido.Visible := AModelo = TModeloNota.NFe;
end;

procedure TfrmNota.FormDestroy(Sender: TObject);
begin
  FController.Free;
end;

procedure TfrmNota.FormShow(Sender: TObject);
begin
  CarregarListas;
  LimparTela;
end;

procedure TfrmNota.CarregarListas;
var
  LClientes: TObjectList<TCliente>;
  LProdutos: TObjectList<TProduto>;
  LFormas: TObjectList<TFormaPagamento>;
  I: Integer;
begin
  LClientes := FController.ListarClientes;
  try
    cbCliente.Properties.Items.Clear;
    SetLength(FIdsClientes, LClientes.Count + 1);
    FIdsClientes[0] := 0;
    if FModelo = TModeloNota.NFCe then
      cbCliente.Properties.Items.Add('(Consumidor não identificado)')
    else
      cbCliente.Properties.Items.Add('(Selecione o destinatário)');
    for I := 0 to LClientes.Count - 1 do
    begin
      FIdsClientes[I + 1] := LClientes[I].Id;
      cbCliente.Properties.Items.Add(LClientes[I].Nome + '  -  ' + FormatarCpfCnpj(LClientes[I].CpfCnpj));
    end;
  finally
    LClientes.Free;
  end;

  LProdutos := FController.ListarProdutos;
  try
    cbProduto.Properties.Items.Clear;
    SetLength(FIdsProdutos, LProdutos.Count);
    for I := 0 to LProdutos.Count - 1 do
    begin
      FIdsProdutos[I] := LProdutos[I].Id;
      cbProduto.Properties.Items.Add(Format('%s - %s  (R$ %s)', [LProdutos[I].Codigo,
        LProdutos[I].Descricao, FormatCurr(FMT_VALOR, LProdutos[I].Preco)]));
    end;
  finally
    LProdutos.Free;
  end;

  LFormas := FController.ListarFormasPagamento;
  try
    cbFormaPagamento.Properties.Items.Clear;
    SetLength(FIdsFormas, LFormas.Count);
    for I := 0 to LFormas.Count - 1 do
    begin
      FIdsFormas[I] := LFormas[I].Id;
      cbFormaPagamento.Properties.Items.Add(LFormas[I].Descricao);
    end;
  finally
    LFormas.Free;
  end;
end;

procedure TfrmNota.LimparTela;
begin
  cbCliente.ItemIndex := 0;
  edtCpfConsumidor.Clear;
  edtObservacao.Clear;
  cbProduto.ItemIndex := -1;
  edtQuantidade.Value := 1;
  edtDesconto.Value := 0;
  if cbFormaPagamento.Properties.Items.Count > 0 then
    cbFormaPagamento.ItemIndex := 0;
  AtualizarTela;
end;

procedure TfrmNota.AtualizarTela;
var
  LNota: TNota;
  LItem: TItemNota;
  LPagamento: TPagamentoNota;
  I: Integer;
begin
  LNota := FController.Nota;

  tvItens.BeginUpdate;
  try
    tvItens.DataController.RecordCount := LNota.Itens.Count;
    for I := 0 to LNota.Itens.Count - 1 do
    begin
      LItem := LNota.Itens[I];
      tvItens.DataController.Values[I, tvItensNumero.Index] := LItem.NumeroItem;
      tvItens.DataController.Values[I, tvItensCodigo.Index] := LItem.Codigo;
      tvItens.DataController.Values[I, tvItensDescricao.Index] := LItem.Descricao;
      tvItens.DataController.Values[I, tvItensQuantidade.Index] := LItem.Quantidade;
      tvItens.DataController.Values[I, tvItensUnitario.Index] := LItem.ValorUnitario;
      tvItens.DataController.Values[I, tvItensDesconto.Index] := LItem.ValorDesconto;
      tvItens.DataController.Values[I, tvItensTotal.Index] := LItem.ValorTotal;
    end;
  finally
    tvItens.EndUpdate;
  end;

  tvPagamentos.BeginUpdate;
  try
    tvPagamentos.DataController.RecordCount := LNota.Pagamentos.Count;
    for I := 0 to LNota.Pagamentos.Count - 1 do
    begin
      LPagamento := LNota.Pagamentos[I];
      tvPagamentos.DataController.Values[I, tvPagamentosForma.Index] := LPagamento.Descricao;
      tvPagamentos.DataController.Values[I, tvPagamentosValor.Index] := LPagamento.Valor;
    end;
  finally
    tvPagamentos.EndUpdate;
  end;

  lblProdutos.Caption := 'Produtos: R$ ' + FormatCurr(FMT_VALOR, LNota.ValorProdutos);
  lblDesconto.Caption := 'Desconto: R$ ' + FormatCurr(FMT_VALOR, LNota.ValorDesconto);
  lblTotal.Caption := 'TOTAL: R$ ' + FormatCurr(FMT_VALOR, LNota.ValorTotal);
  lblPago.Caption := 'Pago: R$ ' + FormatCurr(FMT_VALOR, LNota.TotalPago);
  lblTroco.Caption := 'Troco: R$ ' + FormatCurr(FMT_VALOR, LNota.ValorTroco);

  // sugere o que falta pagar
  edtValorPagamento.Value := FController.ValorRestante;
  btnEmitir.Enabled := LNota.Itens.Count > 0;
  btnImportarPedido.Enabled := LNota.Editavel and (LNota.Itens.Count = 0);
end;

procedure TfrmNota.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_F2: cbProduto.SetFocus;
    VK_F5: if btnEmitir.Enabled then btnEmitir.Click;
    VK_F6: cbFormaPagamento.SetFocus;
  end;
end;

procedure TfrmNota.cbClientePropertiesChange(Sender: TObject);
begin
  if (FController <> nil) and (cbCliente.ItemIndex >= 0) then
    FController.DefinirCliente(FIdsClientes[cbCliente.ItemIndex]);
end;

procedure TfrmNota.edtQuantidadeKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then
    btnAdicionarItem.Click;
end;

procedure TfrmNota.btnAdicionarItemClick(Sender: TObject);
begin
  if cbProduto.ItemIndex < 0 then
    raise EValidacao.Create('Selecione o produto');
  FController.AdicionarItem(FIdsProdutos[cbProduto.ItemIndex], edtQuantidade.Value);
  edtQuantidade.Value := 1;
  AtualizarTela;
  cbProduto.SetFocus;
end;

procedure TfrmNota.btnRemoverItemClick(Sender: TObject);
begin
  if tvItens.DataController.FocusedRecordIndex < 0 then
    raise EValidacao.Create('Selecione o item a remover');
  FController.RemoverItem(tvItens.DataController.FocusedRecordIndex);
  AtualizarTela;
end;

procedure TfrmNota.SelecionarCliente(AClienteId: Integer);
var
  I: Integer;
begin
  for I := 0 to High(FIdsClientes) do
    if FIdsClientes[I] = AClienteId then
    begin
      cbCliente.ItemIndex := I;
      Exit;
    end;
end;

procedure TfrmNota.btnImportarPedidoClick(Sender: TObject);
var
  LPedidoId: Integer;
  LImportou: Boolean;
begin
  LPedidoId := TfrmPedidoApi.Escolher;
  if LPedidoId = 0 then
    Exit;

  Screen.Cursor := crHourGlass;
  try
    LImportou := FController.ImportarPedido(LPedidoId,
      function(ACliente: TClienteApi): Integer
      begin
        Screen.Cursor := crDefault;
        Result := TfrmCliente.CadastrarComDados(ACliente.Nome, ACliente.Documento, ACliente.Email,
          ACliente.Telefone);
        Screen.Cursor := crHourGlass;
      end,
      function(AItem: TItemPedidoApi): Integer
      begin
        Screen.Cursor := crDefault;
        Result := TfrmVinculoProduto.Escolher(AItem);
        Screen.Cursor := crHourGlass;
      end);
  finally
    Screen.Cursor := crDefault;
  end;
  if not LImportou then
    Exit;

  // um cliente cadastrado agora ainda não está no combo
  CarregarListas;
  if cbFormaPagamento.Properties.Items.Count > 0 then
    cbFormaPagamento.ItemIndex := 0;
  SelecionarCliente(FController.Nota.ClienteId);
  edtObservacao.Text := FController.Nota.Observacao;
  AtualizarTela;
  cbFormaPagamento.SetFocus;
end;

procedure TfrmNota.btnAplicarDescontoClick(Sender: TObject);
begin
  FController.AplicarDesconto(edtDesconto.Value);
  AtualizarTela;
end;

procedure TfrmNota.btnAdicionarPagamentoClick(Sender: TObject);
begin
  if cbFormaPagamento.ItemIndex < 0 then
    raise EValidacao.Create('Selecione a forma de pagamento');
  FController.AdicionarPagamento(FIdsFormas[cbFormaPagamento.ItemIndex], edtValorPagamento.Value);
  AtualizarTela;
end;

procedure TfrmNota.btnRemoverPagamentoClick(Sender: TObject);
begin
  if tvPagamentos.DataController.FocusedRecordIndex < 0 then
    raise EValidacao.Create('Selecione o pagamento a remover');
  FController.RemoverPagamento(tvPagamentos.DataController.FocusedRecordIndex);
  AtualizarTela;
end;

procedure TfrmNota.btnNovaNotaClick(Sender: TObject);
begin
  if (FController.Nota.Itens.Count > 0) and FController.Nota.Editavel and
     (MessageDlg('Descartar a nota em digitação?', mtConfirmation, [mbYes, mbNo], 0) <> mrYes) then
    Exit;
  FController.NovaNota;
  LimparTela;
end;

procedure TfrmNota.btnEmitirClick(Sender: TObject);
var
  LResultado: TResultadoOperacao;
begin
  FController.DefinirCpfConsumidor(edtCpfConsumidor.Text);
  FController.DefinirObservacao(edtObservacao.Text);

  Screen.Cursor := crHourGlass;
  try
    LResultado := FController.Emitir;
  finally
    Screen.Cursor := crDefault;
  end;

  if not LResultado.Sucesso then
  begin
    MessageDlg(LResultado.Mensagem, mtWarning, [mbOK], 0);
    AtualizarTela;
    // denegada não volta mais: começa outra nota
    if not FController.Nota.Editavel then
    begin
      FController.NovaNota;
      LimparTela;
    end;
    Exit;
  end;

  if MessageDlg(LResultado.Mensagem + sLineBreak + sLineBreak + 'Imprimir o DANFE agora?',
    mtInformation, [mbYes, mbNo], 0) = mrYes then
    FController.Imprimir;

  FController.NovaNota;
  LimparTela;
end;

end.
