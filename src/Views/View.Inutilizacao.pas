unit View.Inutilizacao;

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, System.UITypes, Vcl.Menus, Vcl.StdCtrls, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, dxLayoutContainer, dxLayoutControl,
  dxLayoutcxEditAdapters, dxLayoutControlAdapters, cxButtons, cxTextEdit, cxMaskEdit,
  cxDropDownEdit, cxSpinEdit, cxMemo, cxClasses, dxCore, dxUIAClasses,
  Controller.ConsultaNota;

type
  TfrmInutilizacao = class(TForm)
    lcInutilizacao: TdxLayoutControl;
    lcInutilizacaoGroup_Root: TdxLayoutGroup;
    cbModelo: TcxComboBox;
    edtSerie: TcxSpinEdit;
    edtNumeroInicial: TcxSpinEdit;
    edtNumeroFinal: TcxSpinEdit;
    memJustificativa: TcxMemo;
    btnInutilizar: TcxButton;
    btnFechar: TcxButton;
    grpFaixa: TdxLayoutGroup;
    liModelo: TdxLayoutItem;
    liSerie: TdxLayoutItem;
    liNumeroInicial: TdxLayoutItem;
    liNumeroFinal: TdxLayoutItem;
    liJustificativa: TdxLayoutItem;
    grpBotoes: TdxLayoutGroup;
    liInutilizar: TdxLayoutItem;
    liFechar: TdxLayoutItem;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnInutilizarClick(Sender: TObject);
  private
    FController: TConsultaNotaController;
  public
    class procedure Exibir;
  end;

implementation

{$R *.dfm}

uses
  Model.Tipos;

class procedure TfrmInutilizacao.Exibir;
var
  LForm: TfrmInutilizacao;
begin
  LForm := TfrmInutilizacao.Create(nil);
  try
    LForm.ShowModal;
  finally
    LForm.Free;
  end;
end;

procedure TfrmInutilizacao.FormCreate(Sender: TObject);
begin
  FController := TConsultaNotaController.Create;
  cbModelo.ItemIndex := 0;
end;

procedure TfrmInutilizacao.FormDestroy(Sender: TObject);
begin
  FController.Free;
end;

procedure TfrmInutilizacao.btnInutilizarClick(Sender: TObject);
var
  LModelo: TModeloNota;
  LResultado: TResultadoOperacao;
begin
  if cbModelo.ItemIndex = 1 then
    LModelo := TModeloNota.NFCe
  else
    LModelo := TModeloNota.NFe;

  if MessageDlg(Format('Confirma a inutilização da %s série %d, números %d a %d?' + sLineBreak +
    'Esta operação não pode ser desfeita.', [LModelo.Descricao, Integer(edtSerie.Value),
    Integer(edtNumeroInicial.Value), Integer(edtNumeroFinal.Value)]),
    mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;

  Screen.Cursor := crHourGlass;
  try
    LResultado := FController.Inutilizar(LModelo, edtSerie.Value, edtNumeroInicial.Value,
      edtNumeroFinal.Value, memJustificativa.Text);
  finally
    Screen.Cursor := crDefault;
  end;

  if LResultado.Sucesso then
  begin
    MessageDlg(LResultado.Mensagem, mtInformation, [mbOK], 0);
    ModalResult := mrOk;
  end
  else
    MessageDlg(LResultado.Mensagem, mtWarning, [mbOK], 0);
end;

end.
