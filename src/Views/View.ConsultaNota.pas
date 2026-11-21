unit View.ConsultaNota;

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, System.UITypes, Vcl.Menus, Vcl.StdCtrls, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, dxLayoutContainer, dxLayoutControl,
  dxLayoutcxEditAdapters, dxLayoutControlAdapters, cxButtons, cxTextEdit, cxMaskEdit,
  cxDropDownEdit, cxCalendar, cxDateUtils, cxCurrencyEdit, cxStyles, cxCustomData, cxFilter,
  cxData, cxDataStorage, cxNavigator, dxDateRanges, dxScrollbarAnnotations,
  cxGridCustomTableView, cxGridTableView, cxGridCustomView, cxClasses, cxGridLevel, cxGrid,
  dxCore, dxUIAClasses, Controller.ConsultaNota;

type
  TfrmConsultaNota = class(TForm)
    lcConsulta: TdxLayoutControl;
    lcConsultaGroup_Root: TdxLayoutGroup;
    edtDataInicial: TcxDateEdit;
    edtDataFinal: TcxDateEdit;
    cbModelo: TcxComboBox;
    cbStatus: TcxComboBox;
    edtTexto: TcxTextEdit;
    btnPesquisar: TcxButton;
    grdNotas: TcxGrid;
    tvNotas: TcxGridTableView;
    tvNotasId: TcxGridColumn;
    tvNotasData: TcxGridColumn;
    tvNotasModelo: TcxGridColumn;
    tvNotasSerie: TcxGridColumn;
    tvNotasNumero: TcxGridColumn;
    tvNotasCliente: TcxGridColumn;
    tvNotasTotal: TcxGridColumn;
    tvNotasSituacao: TcxGridColumn;
    tvNotasChave: TcxGridColumn;
    tvNotasMotivo: TcxGridColumn;
    lvNotas: TcxGridLevel;
    btnImprimir: TcxButton;
    btnPdf: TcxButton;
    btnEmail: TcxButton;
    btnXml: TcxButton;
    btnCancelar: TcxButton;
    btnCCe: TcxButton;
    btnTransmitir: TcxButton;
    btnFechar: TcxButton;
    grpFiltro: TdxLayoutGroup;
    liDataInicial: TdxLayoutItem;
    liDataFinal: TdxLayoutItem;
    liModelo: TdxLayoutItem;
    liStatus: TdxLayoutItem;
    liTexto: TdxLayoutItem;
    liPesquisar: TdxLayoutItem;
    liNotas: TdxLayoutItem;
    grpAcoes: TdxLayoutGroup;
    liImprimir: TdxLayoutItem;
    liPdf: TdxLayoutItem;
    liEmail: TdxLayoutItem;
    liXml: TdxLayoutItem;
    liCancelar: TdxLayoutItem;
    liCCe: TdxLayoutItem;
    liTransmitir: TdxLayoutItem;
    liFechar: TdxLayoutItem;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure edtTextoKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btnPesquisarClick(Sender: TObject);
    procedure btnImprimirClick(Sender: TObject);
    procedure btnPdfClick(Sender: TObject);
    procedure btnEmailClick(Sender: TObject);
    procedure btnXmlClick(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure btnCCeClick(Sender: TObject);
    procedure btnTransmitirClick(Sender: TObject);
  private
    FController: TConsultaNotaController;
    procedure Pesquisar;
    function IdSelecionado: Integer;
  public
    class procedure Exibir;
  end;

implementation

{$R *.dfm}

uses
  System.Generics.Collections, System.DateUtils, Winapi.ShellAPI, Vcl.FileCtrl, Model.Tipos,
  Model.Nota, View.Justificativa;

class procedure TfrmConsultaNota.Exibir;
var
  LForm: TfrmConsultaNota;
begin
  LForm := TfrmConsultaNota.Create(nil);
  try
    LForm.ShowModal;
  finally
    LForm.Free;
  end;
end;

procedure TfrmConsultaNota.FormCreate(Sender: TObject);
var
  LStatus: TStatusNota;
begin
  FController := TConsultaNotaController.Create;
  edtDataInicial.Date := StartOfTheMonth(Date);
  edtDataFinal.Date := Date;
  cbModelo.ItemIndex := 0;

  cbStatus.Properties.Items.Clear;
  cbStatus.Properties.Items.Add('Todas');
  for LStatus := Low(TStatusNota) to High(TStatusNota) do
    cbStatus.Properties.Items.Add(LStatus.Descricao);
  cbStatus.ItemIndex := 0;
end;

procedure TfrmConsultaNota.FormDestroy(Sender: TObject);
begin
  FController.Free;
end;

procedure TfrmConsultaNota.FormShow(Sender: TObject);
begin
  Pesquisar;
end;

procedure TfrmConsultaNota.Pesquisar;
var
  LFiltro: TFiltroNota;
  LNotas: TObjectList<TNota>;
  I: Integer;
begin
  LFiltro := TFiltroNota.Padrao;
  LFiltro.DataInicial := edtDataInicial.Date;
  LFiltro.DataFinal := edtDataFinal.Date;
  case cbModelo.ItemIndex of
    1: LFiltro.Modelo := 55;
    2: LFiltro.Modelo := 65;
  else
    LFiltro.Modelo := 0;
  end;
  LFiltro.Status := cbStatus.ItemIndex - 1;
  LFiltro.Texto := edtTexto.Text;

  LNotas := FController.Listar(LFiltro);
  try
    tvNotas.BeginUpdate;
    try
      tvNotas.DataController.RecordCount := LNotas.Count;
      for I := 0 to LNotas.Count - 1 do
      begin
        tvNotas.DataController.Values[I, tvNotasId.Index] := LNotas[I].Id;
        tvNotas.DataController.Values[I, tvNotasData.Index] := LNotas[I].DataEmissao;
        tvNotas.DataController.Values[I, tvNotasModelo.Index] := LNotas[I].Modelo.Descricao;
        tvNotas.DataController.Values[I, tvNotasSerie.Index] := LNotas[I].Serie;
        tvNotas.DataController.Values[I, tvNotasNumero.Index] := LNotas[I].Numero;
        if LNotas[I].NomeCliente <> '' then
          tvNotas.DataController.Values[I, tvNotasCliente.Index] := LNotas[I].NomeCliente
        else
          tvNotas.DataController.Values[I, tvNotasCliente.Index] := 'Consumidor';
        tvNotas.DataController.Values[I, tvNotasTotal.Index] := LNotas[I].ValorTotal;
        tvNotas.DataController.Values[I, tvNotasSituacao.Index] := LNotas[I].Status.Descricao;
        tvNotas.DataController.Values[I, tvNotasChave.Index] := LNotas[I].Chave;
        tvNotas.DataController.Values[I, tvNotasMotivo.Index] := LNotas[I].Motivo;
      end;
    finally
      tvNotas.EndUpdate;
    end;
  finally
    LNotas.Free;
  end;
end;

function TfrmConsultaNota.IdSelecionado: Integer;
var
  LIndice: Integer;
begin
  LIndice := tvNotas.DataController.FocusedRecordIndex;
  if LIndice < 0 then
    raise EValidacao.Create('Selecione uma nota');
  Result := tvNotas.DataController.Values[LIndice, tvNotasId.Index];
end;

procedure TfrmConsultaNota.edtTextoKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then
    Pesquisar;
end;

procedure TfrmConsultaNota.btnPesquisarClick(Sender: TObject);
begin
  Pesquisar;
end;

procedure TfrmConsultaNota.btnImprimirClick(Sender: TObject);
begin
  FController.Imprimir(IdSelecionado);
end;

procedure TfrmConsultaNota.btnPdfClick(Sender: TObject);
var
  LArquivo: string;
begin
  LArquivo := FController.GerarPdf(IdSelecionado);
  if FileExists(LArquivo) then
    ShellExecute(Handle, 'open', PChar(LArquivo), nil, nil, SW_SHOWNORMAL)
  else
    MessageDlg('PDF gerado em: ' + LArquivo, mtInformation, [mbOK], 0);
end;

procedure TfrmConsultaNota.btnEmailClick(Sender: TObject);
var
  LId: Integer;
  LEmail: string;
  LResultado: TResultadoOperacao;
begin
  LId := IdSelecionado;
  LEmail := FController.EmailDoCliente(LId);
  // InputQuery da VCL: o DevExpress não tem um diálogo de uma linha equivalente
  if not InputQuery('Enviar por e-mail', 'E-mail do destinatário:', LEmail) then
    Exit;

  Screen.Cursor := crHourGlass;
  try
    LResultado := FController.EnviarEmail(LId, LEmail);
  finally
    Screen.Cursor := crDefault;
  end;
  if LResultado.Sucesso then
    MessageDlg(LResultado.Mensagem, mtInformation, [mbOK], 0)
  else
    MessageDlg(LResultado.Mensagem, mtWarning, [mbOK], 0);
end;

procedure TfrmConsultaNota.btnXmlClick(Sender: TObject);
var
  LId: Integer;
  LPasta: string;
begin
  LId := IdSelecionado;
  // SelectDirectory da VCL: não há seletor de pasta no DevExpress
  if not SelectDirectory('Pasta de destino do XML', '', LPasta, [sdNewFolder, sdNewUI]) then
    Exit;
  MessageDlg('XML salvo em:' + sLineBreak + FController.ExportarXml(LId, LPasta),
    mtInformation, [mbOK], 0);
end;

procedure TfrmConsultaNota.btnCancelarClick(Sender: TObject);
var
  LId: Integer;
  LJustificativa: string;
  LResultado: TResultadoOperacao;
begin
  LId := IdSelecionado;
  if not TfrmJustificativa.Solicitar('Cancelamento',
    'Informe o motivo do cancelamento. Ele vai para a SEFAZ e não pode ser alterado depois.',
    JUSTIFICATIVA_MINIMO, JUSTIFICATIVA_MAXIMO, LJustificativa) then
    Exit;

  Screen.Cursor := crHourGlass;
  try
    LResultado := FController.Cancelar(LId, LJustificativa);
  finally
    Screen.Cursor := crDefault;
  end;
  if LResultado.Sucesso then
    MessageDlg(LResultado.Mensagem, mtInformation, [mbOK], 0)
  else
    MessageDlg(LResultado.Mensagem, mtWarning, [mbOK], 0);
  Pesquisar;
end;

procedure TfrmConsultaNota.btnCCeClick(Sender: TObject);
var
  LId: Integer;
  LCorrecao: string;
  LResultado: TResultadoOperacao;
begin
  LId := IdSelecionado;
  if not TfrmJustificativa.Solicitar('Carta de correção',
    'Descreva a correção. A CC-e não pode alterar valores, impostos, dados do emitente/destinatário ' +
    'nem a data de emissão. Uma nova carta substitui a anterior.',
    JUSTIFICATIVA_MINIMO, CORRECAO_MAXIMO, LCorrecao) then
    Exit;

  Screen.Cursor := crHourGlass;
  try
    LResultado := FController.CartaCorrecao(LId, LCorrecao);
  finally
    Screen.Cursor := crDefault;
  end;
  if LResultado.Sucesso then
    MessageDlg(LResultado.Mensagem, mtInformation, [mbOK], 0)
  else
    MessageDlg(LResultado.Mensagem, mtWarning, [mbOK], 0);
end;

procedure TfrmConsultaNota.btnTransmitirClick(Sender: TObject);
var
  LResultado: TResultadoOperacao;
begin
  Screen.Cursor := crHourGlass;
  try
    LResultado := FController.TransmitirContingencia(IdSelecionado);
  finally
    Screen.Cursor := crDefault;
  end;
  if LResultado.Sucesso then
    MessageDlg(LResultado.Mensagem, mtInformation, [mbOK], 0)
  else
    MessageDlg(LResultado.Mensagem, mtWarning, [mbOK], 0);
  Pesquisar;
end;

end.
