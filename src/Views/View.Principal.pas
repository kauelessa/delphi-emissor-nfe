unit View.Principal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls,
  Vcl.Forms, Vcl.Dialogs, System.UITypes, Vcl.Menus, Vcl.StdCtrls, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, dxLayoutContainer, dxLayoutControl,
  dxLayoutcxEditAdapters, dxLayoutControlAdapters, cxButtons, cxLabel, dxStatusBar, dxSkinsCore,
  dxSkinWXI, dxSkinsForm, cxClasses, dxCore, Controller.Principal;

type
  TfrmPrincipal = class(TForm)
    skinController: TdxSkinController;
    sbPrincipal: TdxStatusBar;
    lcPrincipal: TdxLayoutControl;
    lcPrincipalGroup_Root: TdxLayoutGroup;
    lblTitulo: TcxLabel;
    lblAmbiente: TcxLabel;
    btnNFCe: TcxButton;
    btnNFe: TcxButton;
    btnNotas: TcxButton;
    btnClientes: TcxButton;
    btnProdutos: TcxButton;
    btnFormasPagamento: TcxButton;
    btnEmitente: TcxButton;
    btnStatusSefaz: TcxButton;
    btnInutilizar: TcxButton;
    btnSair: TcxButton;
    liTitulo: TdxLayoutItem;
    liAmbiente: TdxLayoutItem;
    grpEmissao: TdxLayoutGroup;
    liNFCe: TdxLayoutItem;
    liNFe: TdxLayoutItem;
    liNotas: TdxLayoutItem;
    grpCadastros: TdxLayoutGroup;
    liClientes: TdxLayoutItem;
    liProdutos: TdxLayoutItem;
    liFormasPagamento: TdxLayoutItem;
    liEmitente: TdxLayoutItem;
    grpSefaz: TdxLayoutGroup;
    liStatusSefaz: TdxLayoutItem;
    liInutilizar: TdxLayoutItem;
    liSair: TdxLayoutItem;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btnNFCeClick(Sender: TObject);
    procedure btnNFeClick(Sender: TObject);
    procedure btnNotasClick(Sender: TObject);
    procedure btnClientesClick(Sender: TObject);
    procedure btnProdutosClick(Sender: TObject);
    procedure btnFormasPagamentoClick(Sender: TObject);
    procedure btnEmitenteClick(Sender: TObject);
    procedure btnStatusSefazClick(Sender: TObject);
    procedure btnInutilizarClick(Sender: TObject);
    procedure btnSairClick(Sender: TObject);
  private
    FController: TPrincipalController;
    procedure TratarExcecao(Sender: TObject; E: Exception);
    procedure AtualizarStatus;
  end;

var
  frmPrincipal: TfrmPrincipal;

implementation

{$R *.dfm}

uses
  Model.Tipos, View.Nota, View.ConsultaNota, View.Cliente, View.Produto, View.FormaPagamento,
  View.Emitente, View.Inutilizacao, Controller.PedidoApi;

procedure TfrmPrincipal.FormCreate(Sender: TObject);
begin
  FController := TPrincipalController.Create;
  Application.OnException := TratarExcecao;

  if FController.Homologacao then
  begin
    lblAmbiente.Caption := 'HOMOLOGAÇÃO - notas sem valor fiscal';
    lblAmbiente.Style.Font.Color := clGreen;
  end
  else
  begin
    lblAmbiente.Caption := 'ATENÇÃO: AMBIENTE DE PRODUÇÃO';
    lblAmbiente.Style.Font.Color := clRed;
  end;
end;

procedure TfrmPrincipal.FormDestroy(Sender: TObject);
begin
  Application.OnException := nil;
  FController.Free;
end;

procedure TfrmPrincipal.FormShow(Sender: TObject);
begin
  AtualizarStatus;
  if not FController.ConfigEncontrado then
    MessageDlg('Arquivo config.ini não encontrado.' + sLineBreak + sLineBreak +
      'Copie o config.example.ini para a pasta do executável com o nome config.ini ' +
      'e preencha os dados do banco e do certificado.', mtWarning, [mbOK], 0)
  else
    TPedidoApiController.ReenviarAvisosPendentes;
end;

procedure TfrmPrincipal.AtualizarStatus;
begin
  sbPrincipal.Panels[0].Text := FController.DescricaoAmbiente;
  sbPrincipal.Panels[1].Text := FController.DescricaoEmitente;
end;

procedure TfrmPrincipal.TratarExcecao(Sender: TObject; E: Exception);
begin
  // regra de negócio violada é aviso; o resto é erro inesperado e vai para o log
  if E is EValidacao then
    MessageDlg(E.Message, mtWarning, [mbOK], 0)
  else
  begin
    FController.RegistrarErro(E.ClassName + ': ' + E.Message);
    MessageDlg('Ocorreu um erro inesperado:' + sLineBreak + sLineBreak + E.Message, mtError, [mbOK], 0);
  end;
end;

procedure TfrmPrincipal.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_F2: btnNFCe.Click;
    VK_F3: btnNFe.Click;
    VK_F4: btnNotas.Click;
  end;
end;

procedure TfrmPrincipal.btnNFCeClick(Sender: TObject);
begin
  TfrmNota.Exibir(TModeloNota.NFCe);
end;

procedure TfrmPrincipal.btnNFeClick(Sender: TObject);
begin
  TfrmNota.Exibir(TModeloNota.NFe);
end;

procedure TfrmPrincipal.btnNotasClick(Sender: TObject);
begin
  TfrmConsultaNota.Exibir;
end;

procedure TfrmPrincipal.btnClientesClick(Sender: TObject);
begin
  TfrmCliente.Exibir;
end;

procedure TfrmPrincipal.btnProdutosClick(Sender: TObject);
begin
  TfrmProduto.Exibir;
end;

procedure TfrmPrincipal.btnFormasPagamentoClick(Sender: TObject);
begin
  TfrmFormaPagamento.Exibir;
end;

procedure TfrmPrincipal.btnEmitenteClick(Sender: TObject);
begin
  TfrmEmitente.Exibir;
  AtualizarStatus;
end;

procedure TfrmPrincipal.btnStatusSefazClick(Sender: TObject);
var
  LNFe, LNFCe: TResultadoOperacao;
begin
  Screen.Cursor := crHourGlass;
  try
    LNFe := FController.StatusServico(TModeloNota.NFe);
    LNFCe := FController.StatusServico(TModeloNota.NFCe);
  finally
    Screen.Cursor := crDefault;
  end;
  MessageDlg('NF-e:  ' + LNFe.Mensagem + sLineBreak + sLineBreak + 'NFC-e: ' + LNFCe.Mensagem,
    mtInformation, [mbOK], 0);
end;

procedure TfrmPrincipal.btnInutilizarClick(Sender: TObject);
begin
  TfrmInutilizacao.Exibir;
end;

procedure TfrmPrincipal.btnSairClick(Sender: TObject);
begin
  Close;
end;

end.
