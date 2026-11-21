unit View.Produto;

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, System.UITypes, Vcl.Menus, Vcl.StdCtrls, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, dxLayoutContainer, dxLayoutControl,
  dxLayoutcxEditAdapters, dxLayoutControlAdapters, cxButtons, cxTextEdit, cxMaskEdit,
  cxDropDownEdit, cxCurrencyEdit, cxPC, dxBarBuiltInMenu, cxStyles, cxCustomData, cxFilter,
  cxData, cxDataStorage, cxNavigator, dxDateRanges, dxScrollbarAnnotations,
  cxGridCustomTableView, cxGridTableView, cxGridCustomView, cxClasses, cxGridLevel, cxGrid,
  dxCore, dxUIAClasses, Controller.Produto;

type
  TfrmProduto = class(TForm)
    pcProduto: TcxPageControl;
    tsLista: TcxTabSheet;
    tsCadastro: TcxTabSheet;
    lcLista: TdxLayoutControl;
    lcListaGroup_Root: TdxLayoutGroup;
    edtFiltro: TcxTextEdit;
    btnPesquisar: TcxButton;
    grdProdutos: TcxGrid;
    tvProdutos: TcxGridTableView;
    tvProdutosId: TcxGridColumn;
    tvProdutosCodigo: TcxGridColumn;
    tvProdutosDescricao: TcxGridColumn;
    tvProdutosNCM: TcxGridColumn;
    tvProdutosCst: TcxGridColumn;
    tvProdutosUnidade: TcxGridColumn;
    tvProdutosPreco: TcxGridColumn;
    lvProdutos: TcxGridLevel;
    btnNovo: TcxButton;
    btnEditar: TcxButton;
    btnInativar: TcxButton;
    btnFechar: TcxButton;
    grpFiltro: TdxLayoutGroup;
    liFiltro: TdxLayoutItem;
    liPesquisar: TdxLayoutItem;
    liProdutos: TdxLayoutItem;
    grpBotoesLista: TdxLayoutGroup;
    liNovo: TdxLayoutItem;
    liEditar: TdxLayoutItem;
    liInativar: TdxLayoutItem;
    liFechar: TdxLayoutItem;
    lcCadastro: TdxLayoutControl;
    lcCadastroGroup_Root: TdxLayoutGroup;
    edtCodigo: TcxTextEdit;
    edtDescricao: TcxTextEdit;
    edtEAN: TcxTextEdit;
    edtUnidade: TcxTextEdit;
    edtPreco: TcxCurrencyEdit;
    edtNCM: TcxMaskEdit;
    edtCEST: TcxMaskEdit;
    edtCFOP: TcxMaskEdit;
    cbOrigem: TcxComboBox;
    cbCstCsosn: TcxComboBox;
    edtAliquotaICMS: TcxCurrencyEdit;
    edtReducaoBC: TcxCurrencyEdit;
    cbCstPIS: TcxComboBox;
    edtAliquotaPIS: TcxCurrencyEdit;
    cbCstCOFINS: TcxComboBox;
    edtAliquotaCOFINS: TcxCurrencyEdit;
    btnSalvar: TcxButton;
    btnCancelar: TcxButton;
    grpDados: TdxLayoutGroup;
    grpDados1: TdxLayoutGroup;
    liCodigo: TdxLayoutItem;
    liDescricao: TdxLayoutItem;
    grpDados2: TdxLayoutGroup;
    liEAN: TdxLayoutItem;
    liUnidade: TdxLayoutItem;
    liPreco: TdxLayoutItem;
    grpFiscal: TdxLayoutGroup;
    grpFiscal1: TdxLayoutGroup;
    liNCM: TdxLayoutItem;
    liCEST: TdxLayoutItem;
    liCFOP: TdxLayoutItem;
    liOrigem: TdxLayoutItem;
    grpFiscal2: TdxLayoutGroup;
    liCstCsosn: TdxLayoutItem;
    liAliquotaICMS: TdxLayoutItem;
    liReducaoBC: TdxLayoutItem;
    grpFiscal3: TdxLayoutGroup;
    liCstPIS: TdxLayoutItem;
    liAliquotaPIS: TdxLayoutItem;
    liCstCOFINS: TdxLayoutItem;
    liAliquotaCOFINS: TdxLayoutItem;
    grpBotoesCadastro: TdxLayoutGroup;
    liSalvar: TdxLayoutItem;
    liCancelar: TdxLayoutItem;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure edtFiltroKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btnPesquisarClick(Sender: TObject);
    procedure btnNovoClick(Sender: TObject);
    procedure btnEditarClick(Sender: TObject);
    procedure btnInativarClick(Sender: TObject);
    procedure btnSalvarClick(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure tvProdutosDblClick(Sender: TObject);
  private
    FController: TProdutoController;
    FProdutoId: Integer;
    procedure Pesquisar;
    function IdSelecionado: Integer;
    procedure LimparCadastro;
    // os combos mostram "código - descrição"; o que vai para o model é só o código
    function CodigoDoCombo(ACombo: TcxComboBox): string;
    procedure SelecionarCodigo(ACombo: TcxComboBox; const ACodigo: string);
  public
    class procedure Exibir;
  end;

implementation

{$R *.dfm}

uses
  System.Generics.Collections, Model.Tipos, Model.Produto;

class procedure TfrmProduto.Exibir;
var
  LForm: TfrmProduto;
begin
  LForm := TfrmProduto.Create(nil);
  try
    LForm.ShowModal;
  finally
    LForm.Free;
  end;
end;

procedure TfrmProduto.FormCreate(Sender: TObject);
begin
  FController := TProdutoController.Create;
  pcProduto.ActivePage := tsLista;
end;

procedure TfrmProduto.FormDestroy(Sender: TObject);
begin
  FController.Free;
end;

procedure TfrmProduto.FormShow(Sender: TObject);
begin
  Pesquisar;
end;

function TfrmProduto.CodigoDoCombo(ACombo: TcxComboBox): string;
var
  LTexto: string;
  LPos: Integer;
begin
  LTexto := Trim(ACombo.Text);
  LPos := Pos(' ', LTexto);
  if LPos > 0 then
    Result := Copy(LTexto, 1, LPos - 1)
  else
    Result := LTexto;
end;

procedure TfrmProduto.SelecionarCodigo(ACombo: TcxComboBox; const ACodigo: string);
var
  I: Integer;
begin
  for I := 0 to ACombo.Properties.Items.Count - 1 do
    if ACombo.Properties.Items[I].StartsWith(ACodigo + ' ') then
    begin
      ACombo.ItemIndex := I;
      Exit;
    end;
  ACombo.Text := ACodigo;
end;

procedure TfrmProduto.Pesquisar;
var
  LProdutos: TObjectList<TProduto>;
  I: Integer;
begin
  LProdutos := FController.Listar(edtFiltro.Text);
  try
    tvProdutos.BeginUpdate;
    try
      tvProdutos.DataController.RecordCount := LProdutos.Count;
      for I := 0 to LProdutos.Count - 1 do
      begin
        tvProdutos.DataController.Values[I, tvProdutosId.Index] := LProdutos[I].Id;
        tvProdutos.DataController.Values[I, tvProdutosCodigo.Index] := LProdutos[I].Codigo;
        tvProdutos.DataController.Values[I, tvProdutosDescricao.Index] := LProdutos[I].Descricao;
        tvProdutos.DataController.Values[I, tvProdutosNCM.Index] := LProdutos[I].NCM;
        tvProdutos.DataController.Values[I, tvProdutosCst.Index] := LProdutos[I].CstCsosn;
        tvProdutos.DataController.Values[I, tvProdutosUnidade.Index] := LProdutos[I].Unidade;
        tvProdutos.DataController.Values[I, tvProdutosPreco.Index] := LProdutos[I].Preco;
      end;
    finally
      tvProdutos.EndUpdate;
    end;
  finally
    LProdutos.Free;
  end;
end;

function TfrmProduto.IdSelecionado: Integer;
var
  LIndice: Integer;
begin
  LIndice := tvProdutos.DataController.FocusedRecordIndex;
  if LIndice < 0 then
    raise EValidacao.Create('Selecione um produto');
  Result := tvProdutos.DataController.Values[LIndice, tvProdutosId.Index];
end;

procedure TfrmProduto.LimparCadastro;
begin
  FProdutoId := 0;
  edtCodigo.Clear;
  edtDescricao.Clear;
  edtEAN.Text := 'SEM GTIN';
  edtUnidade.Text := 'UN';
  edtPreco.Value := 0;
  edtNCM.Clear;
  edtCEST.Clear;
  edtCFOP.Text := '5102';
  cbOrigem.ItemIndex := 0;
  SelecionarCodigo(cbCstCsosn, '102');
  edtAliquotaICMS.Value := 0;
  edtReducaoBC.Value := 0;
  SelecionarCodigo(cbCstPIS, '49');
  edtAliquotaPIS.Value := 0;
  SelecionarCodigo(cbCstCOFINS, '49');
  edtAliquotaCOFINS.Value := 0;
end;

procedure TfrmProduto.edtFiltroKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then
    Pesquisar;
end;

procedure TfrmProduto.btnPesquisarClick(Sender: TObject);
begin
  Pesquisar;
end;

procedure TfrmProduto.btnNovoClick(Sender: TObject);
begin
  LimparCadastro;
  pcProduto.ActivePage := tsCadastro;
  edtCodigo.SetFocus;
end;

procedure TfrmProduto.btnEditarClick(Sender: TObject);
var
  LProduto: TProduto;
begin
  LProduto := FController.Obter(IdSelecionado);
  if LProduto = nil then
    raise EValidacao.Create('Produto não encontrado');
  try
    LimparCadastro;
    FProdutoId := LProduto.Id;
    edtCodigo.Text := LProduto.Codigo;
    edtDescricao.Text := LProduto.Descricao;
    edtEAN.Text := LProduto.EAN;
    edtUnidade.Text := LProduto.Unidade;
    edtPreco.Value := LProduto.Preco;
    edtNCM.Text := LProduto.NCM;
    edtCEST.Text := LProduto.CEST;
    edtCFOP.Text := LProduto.CFOP;
    cbOrigem.ItemIndex := LProduto.Origem;
    SelecionarCodigo(cbCstCsosn, LProduto.CstCsosn);
    edtAliquotaICMS.Value := LProduto.AliquotaICMS;
    edtReducaoBC.Value := LProduto.ReducaoBaseICMS;
    SelecionarCodigo(cbCstPIS, LProduto.CstPIS);
    edtAliquotaPIS.Value := LProduto.AliquotaPIS;
    SelecionarCodigo(cbCstCOFINS, LProduto.CstCOFINS);
    edtAliquotaCOFINS.Value := LProduto.AliquotaCOFINS;
  finally
    LProduto.Free;
  end;
  pcProduto.ActivePage := tsCadastro;
  edtDescricao.SetFocus;
end;

procedure TfrmProduto.btnInativarClick(Sender: TObject);
var
  LId: Integer;
begin
  LId := IdSelecionado;
  if MessageDlg('Inativar o produto selecionado?', mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;
  FController.Inativar(LId);
  Pesquisar;
end;

procedure TfrmProduto.tvProdutosDblClick(Sender: TObject);
begin
  if tvProdutos.DataController.FocusedRecordIndex >= 0 then
    btnEditar.Click;
end;

procedure TfrmProduto.btnSalvarClick(Sender: TObject);
var
  LProduto: TProduto;
begin
  LProduto := TProduto.Create;
  try
    LProduto.Id := FProdutoId;
    LProduto.Codigo := edtCodigo.Text;
    LProduto.Descricao := edtDescricao.Text;
    LProduto.EAN := Trim(edtEAN.Text);
    LProduto.Unidade := edtUnidade.Text;
    LProduto.Preco := edtPreco.Value;
    LProduto.NCM := edtNCM.Text;
    LProduto.CEST := edtCEST.Text;
    LProduto.CFOP := edtCFOP.Text;
    LProduto.Origem := cbOrigem.ItemIndex;
    LProduto.CstCsosn := CodigoDoCombo(cbCstCsosn);
    LProduto.AliquotaICMS := edtAliquotaICMS.Value;
    LProduto.ReducaoBaseICMS := edtReducaoBC.Value;
    LProduto.CstPIS := CodigoDoCombo(cbCstPIS);
    LProduto.AliquotaPIS := edtAliquotaPIS.Value;
    LProduto.CstCOFINS := CodigoDoCombo(cbCstCOFINS);
    LProduto.AliquotaCOFINS := edtAliquotaCOFINS.Value;
    FController.Salvar(LProduto);
  finally
    LProduto.Free;
  end;
  pcProduto.ActivePage := tsLista;
  Pesquisar;
end;

procedure TfrmProduto.btnCancelarClick(Sender: TObject);
begin
  pcProduto.ActivePage := tsLista;
end;

end.
