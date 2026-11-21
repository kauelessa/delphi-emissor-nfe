unit View.FormaPagamento;

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, System.UITypes, Vcl.Menus, Vcl.StdCtrls, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, dxLayoutContainer, dxLayoutControl,
  dxLayoutcxEditAdapters, dxLayoutControlAdapters, cxButtons, cxTextEdit, cxMaskEdit,
  cxDropDownEdit, cxCheckBox, cxStyles, cxCustomData, cxFilter, cxData, cxDataStorage,
  cxNavigator, dxDateRanges, dxScrollbarAnnotations, cxGridCustomTableView, cxGridTableView,
  cxGridCustomView, cxClasses, cxGridLevel, cxGrid, dxCore, dxUIAClasses,
  Controller.FormaPagamento;

type
  TfrmFormaPagamento = class(TForm)
    lcForma: TdxLayoutControl;
    lcFormaGroup_Root: TdxLayoutGroup;
    grdFormas: TcxGrid;
    tvFormas: TcxGridTableView;
    tvFormasId: TcxGridColumn;
    tvFormasDescricao: TcxGridColumn;
    tvFormasCodigo: TcxGridColumn;
    tvFormasAtivo: TcxGridColumn;
    lvFormas: TcxGridLevel;
    edtDescricao: TcxTextEdit;
    cbCodigoSefaz: TcxComboBox;
    chkAtivo: TcxCheckBox;
    btnNovo: TcxButton;
    btnSalvar: TcxButton;
    btnFechar: TcxButton;
    liFormas: TdxLayoutItem;
    grpEdicao: TdxLayoutGroup;
    liDescricao: TdxLayoutItem;
    liCodigoSefaz: TdxLayoutItem;
    liAtivo: TdxLayoutItem;
    grpBotoes: TdxLayoutGroup;
    liNovo: TdxLayoutItem;
    liSalvar: TdxLayoutItem;
    liFechar: TdxLayoutItem;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure tvFormasFocusedRecordChanged(Sender: TcxCustomGridTableView;
      APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord;
      ANewItemRecordFocusingChanged: Boolean);
    procedure btnNovoClick(Sender: TObject);
    procedure btnSalvarClick(Sender: TObject);
  private
    FController: TFormaPagamentoController;
    FFormaId: Integer;
    procedure Carregar;
    procedure Limpar;
  public
    class procedure Exibir;
  end;

implementation

{$R *.dfm}

uses
  System.Generics.Collections, Model.FormaPagamento;

class procedure TfrmFormaPagamento.Exibir;
var
  LForm: TfrmFormaPagamento;
begin
  LForm := TfrmFormaPagamento.Create(nil);
  try
    LForm.ShowModal;
  finally
    LForm.Free;
  end;
end;

procedure TfrmFormaPagamento.FormCreate(Sender: TObject);
var
  I: Integer;
begin
  FController := TFormaPagamentoController.Create;
  cbCodigoSefaz.Properties.Items.Clear;
  for I := Low(FORMAS_PAGAMENTO_SEFAZ) to High(FORMAS_PAGAMENTO_SEFAZ) do
    cbCodigoSefaz.Properties.Items.Add(FORMAS_PAGAMENTO_SEFAZ[I][0] + ' - ' + FORMAS_PAGAMENTO_SEFAZ[I][1]);
end;

procedure TfrmFormaPagamento.FormDestroy(Sender: TObject);
begin
  FController.Free;
end;

procedure TfrmFormaPagamento.FormShow(Sender: TObject);
begin
  Carregar;
  Limpar;
end;

procedure TfrmFormaPagamento.Carregar;
var
  LFormas: TObjectList<TFormaPagamento>;
  I: Integer;
begin
  LFormas := FController.Listar(False);
  try
    tvFormas.BeginUpdate;
    try
      tvFormas.DataController.RecordCount := LFormas.Count;
      for I := 0 to LFormas.Count - 1 do
      begin
        tvFormas.DataController.Values[I, tvFormasId.Index] := LFormas[I].Id;
        tvFormas.DataController.Values[I, tvFormasDescricao.Index] := LFormas[I].Descricao;
        tvFormas.DataController.Values[I, tvFormasCodigo.Index] := LFormas[I].CodigoSefaz;
        if LFormas[I].Ativo then
          tvFormas.DataController.Values[I, tvFormasAtivo.Index] := 'Sim'
        else
          tvFormas.DataController.Values[I, tvFormasAtivo.Index] := 'Não';
      end;
    finally
      tvFormas.EndUpdate;
    end;
  finally
    LFormas.Free;
  end;
end;

procedure TfrmFormaPagamento.Limpar;
begin
  FFormaId := 0;
  edtDescricao.Clear;
  cbCodigoSefaz.ItemIndex := 0;
  chkAtivo.Checked := True;
end;

procedure TfrmFormaPagamento.tvFormasFocusedRecordChanged(Sender: TcxCustomGridTableView;
  APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord;
  ANewItemRecordFocusingChanged: Boolean);
var
  LForma: TFormaPagamento;
  I: Integer;
begin
  if AFocusedRecord = nil then
    Exit;

  LForma := FController.Obter(AFocusedRecord.Values[tvFormasId.Index]);
  if LForma = nil then
    Exit;
  try
    FFormaId := LForma.Id;
    edtDescricao.Text := LForma.Descricao;
    chkAtivo.Checked := LForma.Ativo;
    for I := Low(FORMAS_PAGAMENTO_SEFAZ) to High(FORMAS_PAGAMENTO_SEFAZ) do
      if FORMAS_PAGAMENTO_SEFAZ[I][0] = LForma.CodigoSefaz then
        cbCodigoSefaz.ItemIndex := I;
  finally
    LForma.Free;
  end;
end;

procedure TfrmFormaPagamento.btnNovoClick(Sender: TObject);
begin
  Limpar;
  edtDescricao.SetFocus;
end;

procedure TfrmFormaPagamento.btnSalvarClick(Sender: TObject);
var
  LForma: TFormaPagamento;
begin
  LForma := TFormaPagamento.Create;
  try
    LForma.Id := FFormaId;
    LForma.Descricao := edtDescricao.Text;
    if cbCodigoSefaz.ItemIndex >= 0 then
      LForma.CodigoSefaz := FORMAS_PAGAMENTO_SEFAZ[cbCodigoSefaz.ItemIndex][0];
    LForma.Ativo := chkAtivo.Checked;
    FController.Salvar(LForma);
  finally
    LForma.Free;
  end;
  Carregar;
  Limpar;
end;

end.
