program EmissorNFe;

uses
  System.SysUtils,
  System.UITypes,
  Vcl.Forms,
  Vcl.Dialogs,
  Model.Tipos in 'src\Models\Model.Tipos.pas',
  Model.Endereco in 'src\Models\Model.Endereco.pas',
  Model.Emitente in 'src\Models\Model.Emitente.pas',
  Model.Cliente in 'src\Models\Model.Cliente.pas',
  Model.Produto in 'src\Models\Model.Produto.pas',
  Model.FormaPagamento in 'src\Models\Model.FormaPagamento.pas',
  Model.ItemNota in 'src\Models\Model.ItemNota.pas',
  Model.Pagamento in 'src\Models\Model.Pagamento.pas',
  Model.Nota in 'src\Models\Model.Nota.pas',
  Model.EventoFiscal in 'src\Models\Model.EventoFiscal.pas',
  Infra.Config in 'src\Infra\Infra.Config.pas',
  Infra.Conexao in 'src\Infra\Infra.Conexao.pas',
  Infra.Log in 'src\Infra\Infra.Log.pas',
  Infra.Documento in 'src\Infra\Infra.Documento.pas',
  Infra.ArquivoXml in 'src\Infra\Infra.ArquivoXml.pas',
  Infra.Migracao in 'src\Infra\Infra.Migracao.pas',
  Repository.Emitente in 'src\Repositories\Repository.Emitente.pas',
  Repository.Cliente in 'src\Repositories\Repository.Cliente.pas',
  Repository.Produto in 'src\Repositories\Repository.Produto.pas',
  Repository.FormaPagamento in 'src\Repositories\Repository.FormaPagamento.pas',
  Repository.Nota in 'src\Repositories\Repository.Nota.pas',
  Repository.EventoFiscal in 'src\Repositories\Repository.EventoFiscal.pas',
  Repository.VinculoProduto in 'src\Repositories\Repository.VinculoProduto.pas',
  Model.PedidoApi in 'src\Models\Model.PedidoApi.pas',
  Infra.ApiPedidos in 'src\Infra\Infra.ApiPedidos.pas',
  Service.FaturamentoPedido in 'src\Services\Service.FaturamentoPedido.pas',
  Service.Calculo in 'src\Services\Service.Calculo.pas',
  Service.RetornoSefaz in 'src\Services\Service.RetornoSefaz.pas',
  Service.EmissorFiscal in 'src\Services\Service.EmissorFiscal.pas',
  Service.ACBr in 'src\Services\Service.ACBr.pas',
  Service.Nota in 'src\Services\Service.Nota.pas',
  Service.Emitente in 'src\Services\Service.Emitente.pas',
  Service.Cliente in 'src\Services\Service.Cliente.pas',
  Service.Produto in 'src\Services\Service.Produto.pas',
  Service.FormaPagamento in 'src\Services\Service.FormaPagamento.pas',
  Controller.Fabrica in 'src\Controllers\Controller.Fabrica.pas',
  Controller.Principal in 'src\Controllers\Controller.Principal.pas',
  Controller.Emitente in 'src\Controllers\Controller.Emitente.pas',
  Controller.Cliente in 'src\Controllers\Controller.Cliente.pas',
  Controller.Produto in 'src\Controllers\Controller.Produto.pas',
  Controller.FormaPagamento in 'src\Controllers\Controller.FormaPagamento.pas',
  Controller.Nota in 'src\Controllers\Controller.Nota.pas',
  Controller.ConsultaNota in 'src\Controllers\Controller.ConsultaNota.pas',
  View.Principal in 'src\Views\View.Principal.pas' {frmPrincipal},
  View.Nota in 'src\Views\View.Nota.pas' {frmNota},
  View.ConsultaNota in 'src\Views\View.ConsultaNota.pas' {frmConsultaNota},
  View.Cliente in 'src\Views\View.Cliente.pas' {frmCliente},
  View.Produto in 'src\Views\View.Produto.pas' {frmProduto},
  View.FormaPagamento in 'src\Views\View.FormaPagamento.pas' {frmFormaPagamento},
  View.Emitente in 'src\Views\View.Emitente.pas' {frmEmitente},
  View.Inutilizacao in 'src\Views\View.Inutilizacao.pas' {frmInutilizacao},
  View.Justificativa in 'src\Views\View.Justificativa.pas' {frmJustificativa};

{$R *.res}

var
  LErro: string;

begin
  {$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := True;
  {$ENDIF}
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Emissor NF-e / NFC-e';

  // único ponto que liga a aplicação ao ACBr
  TFabrica.RegistrarEmissor(CriarEmissorACBr);

  // cria o banco (se configurado) e aplica os scripts pendentes da pasta database
  if not TPrincipalController.PrepararBanco(LErro) then
  begin
    MessageDlg('Não foi possível preparar o banco de dados:' + sLineBreak + sLineBreak + LErro +
      sLineBreak + sLineBreak + 'Confira a seção [Banco] do config.ini.', mtError, [mbOK], 0);
    Exit;
  end;

  Application.CreateForm(TfrmPrincipal, frmPrincipal);
  Application.Run;
end.
