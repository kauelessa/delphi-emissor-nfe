unit View.VinculoProduto;

// Pergunta qual produto do emissor corresponde a um produto da API (só na primeira vez).

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, System.UITypes, Vcl.Menus, Vcl.StdCtrls, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, dxLayoutContainer, dxLayoutControl,
  dxLayoutcxEditAdapters, dxLayoutControlAdapters, cxButtons, cxLabel, cxTextEdit, cxMaskEdit,
  cxDropDownEdit, cxClasses, dxCore, dxUIAClasses, Model.PedidoApi;

type
  TfrmVinculoProduto = class(TForm)
    lcVinculo: TdxLayoutControl;
    lcVinculoGroup_Root: TdxLayoutGroup;
    lblInstrucao: TcxLabel;
    lblItemApi: TcxLabel;
    cbProduto: TcxComboBox;
    lblAviso: TcxLabel;
    btnConfirmar: TcxButton;
    btnCancelar: TcxButton;
    liInstrucao: TdxLayoutItem;
    liItemApi: TdxLayoutItem;
    liProduto: TdxLayoutItem;
    liAviso: TdxLayoutItem;
    grpBotoes: TdxLayoutGroup;
    liConfirmar: TdxLayoutItem;
    liCancelar: TdxLayoutItem;
    procedure btnConfirmarClick(Sender: TObject);
  private
    FIds: TArray<Integer>;
    procedure CarregarProdutos(const ADescricaoApi: string);
  public
    /// Id do produto do emissor escolhido; 0 = cancelou.
    class function Escolher(AItem: TItemPedidoApi): Integer;
  end;

implementation

{$R *.dfm}

uses
  System.Generics.Collections, Model.Produto, Controller.PedidoApi;

class function TfrmVinculoProduto.Escolher(AItem: TItemPedidoApi): Integer;
var
  LForm: TfrmVinculoProduto;
begin
  LForm := TfrmVinculoProduto.Create(nil);
  try
    LForm.lblItemApi.Caption := Format('%s  -  %d x R$ %s  (produto %d na API)',
      [AItem.Descricao, AItem.Quantidade, FormatCurr('#,##0.00', AItem.PrecoUnitario), AItem.ProdutoId]);
    LForm.CarregarProdutos(AItem.Descricao);
    if LForm.ShowModal = mrOk then
      Result := LForm.FIds[LForm.cbProduto.ItemIndex]
    else
      Result := 0;
  finally
    LForm.Free;
  end;
end;

procedure TfrmVinculoProduto.CarregarProdutos(const ADescricaoApi: string);
var
  LProdutos: TObjectList<TProduto>;
  I: Integer;
begin
  LProdutos := TPedidoApiController.ProdutosAtivos;
  try
    cbProduto.Properties.Items.Clear;
    SetLength(FIds, LProdutos.Count);
    for I := 0 to LProdutos.Count - 1 do
    begin
      FIds[I] := LProdutos[I].Id;
      cbProduto.Properties.Items.Add(Format('%s - %s  (NCM %s)',
        [LProdutos[I].Codigo, LProdutos[I].Descricao, LProdutos[I].NCM]));
      // mesma descrição dos dois lados: já deixa sugerido
      if AnsiSameText(Trim(LProdutos[I].Descricao), Trim(ADescricaoApi)) then
        cbProduto.ItemIndex := I;
    end;
  finally
    LProdutos.Free;
  end;
end;

procedure TfrmVinculoProduto.btnConfirmarClick(Sender: TObject);
begin
  if cbProduto.ItemIndex < 0 then
  begin
    MessageDlg('Escolha o produto do emissor.', mtWarning, [mbOK], 0);
    cbProduto.SetFocus;
    Exit;
  end;
  ModalResult := mrOk;
end;

end.
