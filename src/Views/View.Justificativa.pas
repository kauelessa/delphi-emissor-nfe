unit View.Justificativa;

// Diálogo reaproveitado para justificativa de cancelamento e texto da CC-e.

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, System.UITypes, Vcl.Menus, Vcl.StdCtrls, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, dxLayoutContainer, dxLayoutControl,
  dxLayoutcxEditAdapters, dxLayoutControlAdapters, cxButtons, cxLabel, cxTextEdit, cxMemo,
  cxClasses, dxCore, dxUIAClasses;

type
  TfrmJustificativa = class(TForm)
    lcJustificativa: TdxLayoutControl;
    lcJustificativaGroup_Root: TdxLayoutGroup;
    lblInstrucao: TcxLabel;
    memTexto: TcxMemo;
    lblContador: TcxLabel;
    btnConfirmar: TcxButton;
    btnCancelar: TcxButton;
    liInstrucao: TdxLayoutItem;
    liTexto: TdxLayoutItem;
    liContador: TdxLayoutItem;
    grpBotoes: TdxLayoutGroup;
    liConfirmar: TdxLayoutItem;
    liCancelar: TdxLayoutItem;
    procedure memTextoPropertiesChange(Sender: TObject);
    procedure btnConfirmarClick(Sender: TObject);
  private
    FMinimo: Integer;
    FMaximo: Integer;
  public
    class function Solicitar(const ATitulo, AInstrucao: string; AMinimo, AMaximo: Integer;
      out ATexto: string): Boolean;
  end;

implementation

{$R *.dfm}

class function TfrmJustificativa.Solicitar(const ATitulo, AInstrucao: string; AMinimo,
  AMaximo: Integer; out ATexto: string): Boolean;
var
  LForm: TfrmJustificativa;
begin
  LForm := TfrmJustificativa.Create(nil);
  try
    LForm.Caption := ATitulo;
    LForm.lblInstrucao.Caption := AInstrucao;
    LForm.FMinimo := AMinimo;
    LForm.FMaximo := AMaximo;
    LForm.memTexto.Properties.MaxLength := AMaximo;
    LForm.memTextoPropertiesChange(nil);

    Result := LForm.ShowModal = mrOk;
    if Result then
      ATexto := Trim(LForm.memTexto.Text)
    else
      ATexto := '';
  finally
    LForm.Free;
  end;
end;

procedure TfrmJustificativa.memTextoPropertiesChange(Sender: TObject);
begin
  lblContador.Caption := Format('%d de %d caracteres (mínimo %d)',
    [Length(Trim(memTexto.Text)), FMaximo, FMinimo]);
end;

procedure TfrmJustificativa.btnConfirmarClick(Sender: TObject);
begin
  if Length(Trim(memTexto.Text)) < FMinimo then
  begin
    MessageDlg(Format('Digite pelo menos %d caracteres.', [FMinimo]), mtWarning, [mbOK], 0);
    memTexto.SetFocus;
    Exit;
  end;
  ModalResult := mrOk;
end;

end.
