unit Controller.Fabrica;

// Monta os services com as dependências reais (repositórios FireDAC, log, XML).
// O emissor fiscal é registrado pelo .dpr, assim nada aqui depende do ACBr.

interface

uses
  System.SysUtils, Infra.ApiPedidos, Service.EmissorFiscal, Service.Nota, Service.Emitente, Service.Cliente,
  Service.Produto, Service.FormaPagamento, Service.FaturamentoPedido, Service.AvisoFaturamento;

type
  TFabrica = class
  private
    class var FCriarEmissor: TFunc<IEmissorFiscal>;
    class function ApiPedidos: IPedidoApi;
  public
    class procedure RegistrarEmissor(const ACriar: TFunc<IEmissorFiscal>);
    class function NotaService: INotaService;
    class function EmitenteService: IEmitenteService;
    class function ClienteService: IClienteService;
    class function ProdutoService: IProdutoService;
    class function FormaPagamentoService: IFormaPagamentoService;
    class function FaturamentoPedidoService: IFaturamentoPedidoService;
    class function AvisoFaturamento: IAvisoFaturamento;
  end;

implementation

uses
  Infra.Conexao, Infra.Config, Infra.Log, Infra.ArquivoXml, Repository.Nota,
  Repository.Emitente, Repository.Cliente, Repository.Produto, Repository.FormaPagamento,
  Repository.EventoFiscal, Repository.VinculoProduto;

class procedure TFabrica.RegistrarEmissor(const ACriar: TFunc<IEmissorFiscal>);
begin
  FCriarEmissor := ACriar;
end;

class function TFabrica.NotaService: INotaService;
begin
  if not Assigned(FCriarEmissor) then
    raise Exception.Create('Emissor fiscal não registrado (TFabrica.RegistrarEmissor)');

  Result := TNotaService.Create(
    TNotaRepository.Create(Conexao),
    TEmitenteRepository.Create(Conexao),
    TClienteRepository.Create(Conexao),
    TProdutoRepository.Create(Conexao),
    TFormaPagamentoRepository.Create(Conexao),
    TEventoFiscalRepository.Create(Conexao),
    FCriarEmissor(),
    TArquivoXmlDisco.Create(Config.NFe.PastaXml),
    Log,
    AvisoFaturamento);
end;

class function TFabrica.EmitenteService: IEmitenteService;
begin
  Result := TEmitenteService.Create(TEmitenteRepository.Create(Conexao));
end;

class function TFabrica.ClienteService: IClienteService;
begin
  Result := TClienteService.Create(TClienteRepository.Create(Conexao));
end;

class function TFabrica.ProdutoService: IProdutoService;
begin
  Result := TProdutoService.Create(TProdutoRepository.Create(Conexao));
end;

class function TFabrica.FormaPagamentoService: IFormaPagamentoService;
begin
  Result := TFormaPagamentoService.Create(TFormaPagamentoRepository.Create(Conexao));
end;

class function TFabrica.ApiPedidos: IPedidoApi;
begin
  Result := TPedidoApiHttp.Create(TNetHttpTransporte.Create(Config.Api.TimeoutMs), Config.Api.Url,
    Config.Api.Usuario, Config.Api.Senha);
end;

class function TFabrica.AvisoFaturamento: IAvisoFaturamento;
begin
  Result := TAvisoFaturamentoService.Create(ApiPedidos, TNotaRepository.Create(Conexao), Log);
end;

class function TFabrica.FaturamentoPedidoService: IFaturamentoPedidoService;
begin
  Result := TFaturamentoPedidoService.Create(
    ApiPedidos,
    NotaService,
    TNotaRepository.Create(Conexao),
    TClienteRepository.Create(Conexao),
    TProdutoRepository.Create(Conexao),
    TVinculoProdutoRepository.Create(Conexao),
    Log);
end;

end.
