unit View.Emitente;

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, System.UITypes, Vcl.Menus, Vcl.StdCtrls, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, dxLayoutContainer, dxLayoutControl,
  dxLayoutcxEditAdapters, dxLayoutControlAdapters, cxButtons, cxLabel, cxTextEdit, cxMaskEdit,
  cxDropDownEdit, cxSpinEdit, cxClasses, dxCore, dxUIAClasses, Controller.Emitente;

type
  TfrmEmitente = class(TForm)
    lcEmitente: TdxLayoutControl;
    lcEmitenteGroup_Root: TdxLayoutGroup;
    edtRazaoSocial: TcxTextEdit;
    edtNomeFantasia: TcxTextEdit;
    edtCNPJ: TcxMaskEdit;
    edtIE: TcxTextEdit;
    cbCRT: TcxComboBox;
    edtTelefone: TcxTextEdit;
    edtEmail: TcxTextEdit;
    edtLogradouro: TcxTextEdit;
    edtNumero: TcxTextEdit;
    edtComplemento: TcxTextEdit;
    edtBairro: TcxTextEdit;
    edtCodigoMunicipio: TcxMaskEdit;
    edtMunicipio: TcxTextEdit;
    cbUF: TcxComboBox;
    edtCEP: TcxMaskEdit;
    edtSerieNFe: TcxSpinEdit;
    edtProximoNFe: TcxSpinEdit;
    edtSerieNFCe: TcxSpinEdit;
    edtProximoNFCe: TcxSpinEdit;
    lblCertificado: TcxLabel;
    btnSalvar: TcxButton;
    btnFechar: TcxButton;
    grpDados: TdxLayoutGroup;
    grpDados1: TdxLayoutGroup;
    liRazaoSocial: TdxLayoutItem;
    liNomeFantasia: TdxLayoutItem;
    grpDados2: TdxLayoutGroup;
    liCNPJ: TdxLayoutItem;
    liIE: TdxLayoutItem;
    liCRT: TdxLayoutItem;
    grpDados3: TdxLayoutGroup;
    liTelefone: TdxLayoutItem;
    liEmail: TdxLayoutItem;
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
    grpNumeracao: TdxLayoutGroup;
    liSerieNFe: TdxLayoutItem;
    liProximoNFe: TdxLayoutItem;
    liSerieNFCe: TdxLayoutItem;
    liProximoNFCe: TdxLayoutItem;
    liCertificado: TdxLayoutItem;
    grpBotoes: TdxLayoutGroup;
    liSalvar: TdxLayoutItem;
    liFechar: TdxLayoutItem;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnSalvarClick(Sender: TObject);
  private
    FController: TEmitenteController;
    FEmitenteId: Integer;
  public
    class procedure Exibir;
  end;

implementation

{$R *.dfm}

uses
  Model.Tipos, Model.Emitente;

class procedure TfrmEmitente.Exibir;
var
  LForm: TfrmEmitente;
begin
  LForm := TfrmEmitente.Create(nil);
  try
    LForm.ShowModal;
  finally
    LForm.Free;
  end;
end;

procedure TfrmEmitente.FormCreate(Sender: TObject);
begin
  FController := TEmitenteController.Create;
end;

procedure TfrmEmitente.FormDestroy(Sender: TObject);
begin
  FController.Free;
end;

procedure TfrmEmitente.FormShow(Sender: TObject);
var
  LEmitente: TEmitente;
begin
  lblCertificado.Caption := 'Certificado A1: ' + FController.DescricaoCertificado +
    sLineBreak + 'O certificado, a senha e o ambiente ficam no config.ini (não versionado).';

  LEmitente := FController.Obter;
  try
    FEmitenteId := LEmitente.Id;
    edtRazaoSocial.Text := LEmitente.RazaoSocial;
    edtNomeFantasia.Text := LEmitente.NomeFantasia;
    edtCNPJ.Text := LEmitente.CNPJ;
    edtIE.Text := LEmitente.IE;
    cbCRT.ItemIndex := Ord(LEmitente.Regime);
    edtTelefone.Text := LEmitente.Telefone;
    edtEmail.Text := LEmitente.Email;
    edtLogradouro.Text := LEmitente.Endereco.Logradouro;
    edtNumero.Text := LEmitente.Endereco.Numero;
    edtComplemento.Text := LEmitente.Endereco.Complemento;
    edtBairro.Text := LEmitente.Endereco.Bairro;
    if LEmitente.Endereco.CodigoMunicipio > 0 then
      edtCodigoMunicipio.Text := IntToStr(LEmitente.Endereco.CodigoMunicipio);
    edtMunicipio.Text := LEmitente.Endereco.Municipio;
    cbUF.ItemIndex := cbUF.Properties.Items.IndexOf(LEmitente.Endereco.UF);
    edtCEP.Text := LEmitente.Endereco.CEP;
    edtSerieNFe.Value := LEmitente.SerieNFe;
    edtProximoNFe.Value := LEmitente.ProximoNumeroNFe;
    edtSerieNFCe.Value := LEmitente.SerieNFCe;
    edtProximoNFCe.Value := LEmitente.ProximoNumeroNFCe;
  finally
    LEmitente.Free;
  end;
end;

procedure TfrmEmitente.btnSalvarClick(Sender: TObject);
var
  LEmitente: TEmitente;
begin
  LEmitente := TEmitente.Create;
  try
    LEmitente.Id := FEmitenteId;
    LEmitente.RazaoSocial := Trim(edtRazaoSocial.Text);
    LEmitente.NomeFantasia := Trim(edtNomeFantasia.Text);
    LEmitente.CNPJ := edtCNPJ.Text;
    LEmitente.IE := Trim(edtIE.Text);
    LEmitente.Regime := TRegimeTributario(cbCRT.ItemIndex);
    LEmitente.Telefone := edtTelefone.Text;
    LEmitente.Email := Trim(edtEmail.Text);
    LEmitente.Endereco.Logradouro := Trim(edtLogradouro.Text);
    LEmitente.Endereco.Numero := Trim(edtNumero.Text);
    LEmitente.Endereco.Complemento := Trim(edtComplemento.Text);
    LEmitente.Endereco.Bairro := Trim(edtBairro.Text);
    LEmitente.Endereco.CodigoMunicipio := StrToIntDef(edtCodigoMunicipio.Text, 0);
    LEmitente.Endereco.Municipio := Trim(edtMunicipio.Text);
    LEmitente.Endereco.UF := cbUF.Text;
    LEmitente.Endereco.CEP := edtCEP.Text;
    LEmitente.SerieNFe := edtSerieNFe.Value;
    LEmitente.ProximoNumeroNFe := edtProximoNFe.Value;
    LEmitente.SerieNFCe := edtSerieNFCe.Value;
    LEmitente.ProximoNumeroNFCe := edtProximoNFCe.Value;
    FController.Salvar(LEmitente);
    FEmitenteId := LEmitente.Id;
  finally
    LEmitente.Free;
  end;
  MessageDlg('Emitente salvo.', mtInformation, [mbOK], 0);
  ModalResult := mrOk;
end;

end.
