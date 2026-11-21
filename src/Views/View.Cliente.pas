unit View.Cliente;

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, System.UITypes, Vcl.Menus, Vcl.StdCtrls, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, dxLayoutContainer, dxLayoutControl,
  dxLayoutcxEditAdapters, dxLayoutControlAdapters, cxButtons, cxTextEdit, cxMaskEdit,
  cxDropDownEdit, cxPC, dxBarBuiltInMenu, cxStyles, cxCustomData, cxFilter, cxData,
  cxDataStorage, cxNavigator, dxDateRanges, dxScrollbarAnnotations, cxGridCustomTableView,
  cxGridTableView, cxGridCustomView, cxClasses, cxGridLevel, cxGrid, dxCore, dxUIAClasses,
  Controller.Cliente;

type
  TfrmCliente = class(TForm)
    pcCliente: TcxPageControl;
    tsLista: TcxTabSheet;
    tsCadastro: TcxTabSheet;
    lcLista: TdxLayoutControl;
    lcListaGroup_Root: TdxLayoutGroup;
    edtFiltro: TcxTextEdit;
    btnPesquisar: TcxButton;
    grdClientes: TcxGrid;
    tvClientes: TcxGridTableView;
    tvClientesId: TcxGridColumn;
    tvClientesNome: TcxGridColumn;
    tvClientesDocumento: TcxGridColumn;
    tvClientesCidade: TcxGridColumn;
    tvClientesEmail: TcxGridColumn;
    lvClientes: TcxGridLevel;
    btnNovo: TcxButton;
    btnEditar: TcxButton;
    btnInativar: TcxButton;
    btnFechar: TcxButton;
    grpFiltro: TdxLayoutGroup;
    liFiltro: TdxLayoutItem;
    liPesquisar: TdxLayoutItem;
    liClientes: TdxLayoutItem;
    grpBotoesLista: TdxLayoutGroup;
    liNovo: TdxLayoutItem;
    liEditar: TdxLayoutItem;
    liInativar: TdxLayoutItem;
    liFechar: TdxLayoutItem;
    lcCadastro: TdxLayoutControl;
    lcCadastroGroup_Root: TdxLayoutGroup;
    edtNome: TcxTextEdit;
    edtCpfCnpj: TcxTextEdit;
    cbIndicadorIE: TcxComboBox;
    edtIE: TcxTextEdit;
    edtEmail: TcxTextEdit;
    edtTelefone: TcxTextEdit;
    edtLogradouro: TcxTextEdit;
    edtNumero: TcxTextEdit;
    edtComplemento: TcxTextEdit;
    edtBairro: TcxTextEdit;
    edtCodigoMunicipio: TcxMaskEdit;
    edtMunicipio: TcxTextEdit;
    cbUF: TcxComboBox;
    edtCEP: TcxMaskEdit;
    btnSalvar: TcxButton;
    btnCancelar: TcxButton;
    grpDados: TdxLayoutGroup;
    grpLinha1: TdxLayoutGroup;
    liNome: TdxLayoutItem;
    liCpfCnpj: TdxLayoutItem;
    grpLinha2: TdxLayoutGroup;
    liIndicadorIE: TdxLayoutItem;
    liIE: TdxLayoutItem;
    grpLinha3: TdxLayoutGroup;
    liEmail: TdxLayoutItem;
    liTelefone: TdxLayoutItem;
    grpEndereco: TdxLayoutGroup;
    grpEndereco1: TdxLayoutGroup;
    liLogradouro: TdxLayoutItem;
    liNumero: TdxLayoutItem;
    grpEndereco2: TdxLayoutGroup;
    liComplemento: TdxLayoutItem;
    liBairro: TdxLayoutItem;
    grpEndereco3: TdxLayoutGroup;
    liCodigoMunicipio: TdxLayoutItem;
    liMunicipio: TdxLayoutItem;
    liUF: TdxLayoutItem;
    liCEP: TdxLayoutItem;
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
    procedure tvClientesDblClick(Sender: TObject);
  private
    FController: TClienteController;
    FClienteId: Integer;
    procedure Pesquisar;
    function IdSelecionado: Integer;
    procedure LimparCadastro;
  public
    class procedure Exibir;
  end;

implementation

{$R *.dfm}

uses
  System.Generics.Collections, Model.Tipos, Model.Cliente, Infra.Documento;

class procedure TfrmCliente.Exibir;
var
  LForm: TfrmCliente;
begin
  LForm := TfrmCliente.Create(nil);
  try
    LForm.ShowModal;
  finally
    LForm.Free;
  end;
end;

procedure TfrmCliente.FormCreate(Sender: TObject);
begin
  FController := TClienteController.Create;
  pcCliente.ActivePage := tsLista;
end;

procedure TfrmCliente.FormDestroy(Sender: TObject);
begin
  FController.Free;
end;

procedure TfrmCliente.FormShow(Sender: TObject);
begin
  Pesquisar;
end;

procedure TfrmCliente.Pesquisar;
var
  LClientes: TObjectList<TCliente>;
  I: Integer;
begin
  LClientes := FController.Listar(edtFiltro.Text);
  try
    tvClientes.BeginUpdate;
    try
      tvClientes.DataController.RecordCount := LClientes.Count;
      for I := 0 to LClientes.Count - 1 do
      begin
        tvClientes.DataController.Values[I, tvClientesId.Index] := LClientes[I].Id;
        tvClientes.DataController.Values[I, tvClientesNome.Index] := LClientes[I].Nome;
        tvClientes.DataController.Values[I, tvClientesDocumento.Index] := FormatarCpfCnpj(LClientes[I].CpfCnpj);
        if LClientes[I].Endereco.Municipio <> '' then
          tvClientes.DataController.Values[I, tvClientesCidade.Index] :=
            LClientes[I].Endereco.Municipio + '/' + LClientes[I].Endereco.UF
        else
          tvClientes.DataController.Values[I, tvClientesCidade.Index] := '';
        tvClientes.DataController.Values[I, tvClientesEmail.Index] := LClientes[I].Email;
      end;
    finally
      tvClientes.EndUpdate;
    end;
  finally
    LClientes.Free;
  end;
end;

function TfrmCliente.IdSelecionado: Integer;
var
  LIndice: Integer;
begin
  LIndice := tvClientes.DataController.FocusedRecordIndex;
  if LIndice < 0 then
    raise EValidacao.Create('Selecione um cliente');
  Result := tvClientes.DataController.Values[LIndice, tvClientesId.Index];
end;

procedure TfrmCliente.LimparCadastro;
begin
  FClienteId := 0;
  edtNome.Clear;
  edtCpfCnpj.Clear;
  cbIndicadorIE.ItemIndex := 2;
  edtIE.Clear;
  edtEmail.Clear;
  edtTelefone.Clear;
  edtLogradouro.Clear;
  edtNumero.Clear;
  edtComplemento.Clear;
  edtBairro.Clear;
  edtCodigoMunicipio.Clear;
  edtMunicipio.Clear;
  cbUF.ItemIndex := -1;
  edtCEP.Clear;
end;

procedure TfrmCliente.edtFiltroKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then
    Pesquisar;
end;

procedure TfrmCliente.btnPesquisarClick(Sender: TObject);
begin
  Pesquisar;
end;

procedure TfrmCliente.btnNovoClick(Sender: TObject);
begin
  LimparCadastro;
  pcCliente.ActivePage := tsCadastro;
  edtNome.SetFocus;
end;

procedure TfrmCliente.btnEditarClick(Sender: TObject);
var
  LCliente: TCliente;
begin
  LCliente := FController.Obter(IdSelecionado);
  if LCliente = nil then
    raise EValidacao.Create('Cliente não encontrado');
  try
    LimparCadastro;
    FClienteId := LCliente.Id;
    edtNome.Text := LCliente.Nome;
    edtCpfCnpj.Text := FormatarCpfCnpj(LCliente.CpfCnpj);
    cbIndicadorIE.ItemIndex := Ord(LCliente.IndicadorIE);
    edtIE.Text := LCliente.IE;
    edtEmail.Text := LCliente.Email;
    edtTelefone.Text := LCliente.Telefone;
    edtLogradouro.Text := LCliente.Endereco.Logradouro;
    edtNumero.Text := LCliente.Endereco.Numero;
    edtComplemento.Text := LCliente.Endereco.Complemento;
    edtBairro.Text := LCliente.Endereco.Bairro;
    if LCliente.Endereco.CodigoMunicipio > 0 then
      edtCodigoMunicipio.Text := IntToStr(LCliente.Endereco.CodigoMunicipio);
    edtMunicipio.Text := LCliente.Endereco.Municipio;
    cbUF.ItemIndex := cbUF.Properties.Items.IndexOf(LCliente.Endereco.UF);
    edtCEP.Text := LCliente.Endereco.CEP;
  finally
    LCliente.Free;
  end;
  pcCliente.ActivePage := tsCadastro;
  edtNome.SetFocus;
end;

procedure TfrmCliente.btnInativarClick(Sender: TObject);
var
  LId: Integer;
begin
  LId := IdSelecionado;
  if MessageDlg('Inativar o cliente selecionado?', mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;
  FController.Inativar(LId);
  Pesquisar;
end;

procedure TfrmCliente.tvClientesDblClick(Sender: TObject);
begin
  if tvClientes.DataController.FocusedRecordIndex >= 0 then
    btnEditar.Click;
end;

procedure TfrmCliente.btnSalvarClick(Sender: TObject);
var
  LCliente: TCliente;
begin
  LCliente := TCliente.Create;
  try
    LCliente.Id := FClienteId;
    LCliente.Nome := edtNome.Text;
    LCliente.CpfCnpj := edtCpfCnpj.Text;
    LCliente.IndicadorIE := TIndicadorIE(cbIndicadorIE.ItemIndex);
    LCliente.IE := edtIE.Text;
    LCliente.Email := Trim(edtEmail.Text);
    LCliente.Telefone := edtTelefone.Text;
    LCliente.Endereco.Logradouro := Trim(edtLogradouro.Text);
    LCliente.Endereco.Numero := Trim(edtNumero.Text);
    LCliente.Endereco.Complemento := Trim(edtComplemento.Text);
    LCliente.Endereco.Bairro := Trim(edtBairro.Text);
    LCliente.Endereco.CodigoMunicipio := StrToIntDef(edtCodigoMunicipio.Text, 0);
    LCliente.Endereco.Municipio := Trim(edtMunicipio.Text);
    LCliente.Endereco.UF := cbUF.Text;
    LCliente.Endereco.CEP := edtCEP.Text;
    FController.Salvar(LCliente);
  finally
    LCliente.Free;
  end;
  pcCliente.ActivePage := tsLista;
  Pesquisar;
end;

procedure TfrmCliente.btnCancelarClick(Sender: TObject);
begin
  pcCliente.ActivePage := tsLista;
end;

end.
