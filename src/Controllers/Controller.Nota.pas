unit Controller.Nota;

// Estado da tela de emissão: a nota em digitação vive aqui, a view só desenha.

interface

uses
  System.Generics.Collections, Model.Tipos, Model.Nota, Model.Cliente, Model.Produto,
  Model.FormaPagamento, Service.Nota, Service.FaturamentoPedido;

type
  TNotaController = class
  private
    FService: INotaService;
    FNota: TNota;
  public
    constructor Create(AModelo: TModeloNota);
    destructor Destroy; override;

    procedure NovaNota;
    function ListarClientes: TObjectList<TCliente>;
    function ListarProdutos: TObjectList<TProduto>;
    function ListarFormasPagamento: TObjectList<TFormaPagamento>;

    procedure DefinirCliente(AClienteId: Integer);
    procedure DefinirCpfConsumidor(const ACpf: string);
    procedure DefinirObservacao(const ATexto: string);
    procedure AdicionarItem(AProdutoId: Integer; AQuantidade: Currency);
    procedure AdicionarItemPorCodigo(const ACodigo: string; AQuantidade: Currency);
    procedure RemoverItem(AIndice: Integer);
    procedure AplicarDesconto(AValor: Currency);
    procedure AdicionarPagamento(AFormaId: Integer; AValor: Currency);
    procedure RemoverPagamento(AIndice: Integer);
    function ValorRestante: Currency;

    function Emitir: TResultadoOperacao;
    procedure Imprimir;

    function ImportarPedido(APedidoId: Integer; const ACadastrarCliente: TCadastrarCliente;
      const AEscolherProduto: TEscolherProduto): Boolean;

    property Nota: TNota read FNota;
  end;

implementation

uses
  System.SysUtils, System.Math, Controller.Fabrica, Infra.Documento;

constructor TNotaController.Create(AModelo: TModeloNota);
begin
  inherited Create;
  FService := TFabrica.NotaService;
  FNota := FService.NovaNota(AModelo);
end;

destructor TNotaController.Destroy;
begin
  FNota.Free;
  inherited;
end;

procedure TNotaController.NovaNota;
var
  LModelo: TModeloNota;
begin
  LModelo := FNota.Modelo;
  FreeAndNil(FNota);
  FNota := FService.NovaNota(LModelo);
end;

function TNotaController.ListarClientes: TObjectList<TCliente>;
begin
  Result := TFabrica.ClienteService.Listar('');
end;

function TNotaController.ListarProdutos: TObjectList<TProduto>;
begin
  Result := TFabrica.ProdutoService.Listar('');
end;

function TNotaController.ListarFormasPagamento: TObjectList<TFormaPagamento>;
begin
  Result := TFabrica.FormaPagamentoService.Listar(True);
end;

procedure TNotaController.DefinirCliente(AClienteId: Integer);
begin
  FNota.ClienteId := AClienteId;
end;

procedure TNotaController.DefinirCpfConsumidor(const ACpf: string);
begin
  FNota.CpfConsumidor := SoNumeros(ACpf);
end;

procedure TNotaController.DefinirObservacao(const ATexto: string);
begin
  FNota.Observacao := Trim(ATexto);
end;

procedure TNotaController.AdicionarItem(AProdutoId: Integer; AQuantidade: Currency);
begin
  FService.AdicionarItem(FNota, AProdutoId, AQuantidade);
end;

procedure TNotaController.AdicionarItemPorCodigo(const ACodigo: string; AQuantidade: Currency);
begin
  FService.AdicionarItemPorCodigo(FNota, ACodigo, AQuantidade);
end;

procedure TNotaController.RemoverItem(AIndice: Integer);
begin
  FService.RemoverItem(FNota, AIndice);
end;

procedure TNotaController.AplicarDesconto(AValor: Currency);
begin
  FService.AplicarDesconto(FNota, AValor);
end;

procedure TNotaController.AdicionarPagamento(AFormaId: Integer; AValor: Currency);
begin
  FService.AdicionarPagamento(FNota, AFormaId, AValor);
end;

procedure TNotaController.RemoverPagamento(AIndice: Integer);
begin
  FService.RemoverPagamento(FNota, AIndice);
end;

function TNotaController.ImportarPedido(APedidoId: Integer;
  const ACadastrarCliente: TCadastrarCliente; const AEscolherProduto: TEscolherProduto): Boolean;
begin
  Result := TFabrica.FaturamentoPedidoService.Importar(FNota, APedidoId, ACadastrarCliente,
    AEscolherProduto);
end;

function TNotaController.ValorRestante: Currency;
begin
  Result := Max(FNota.ValorTotal - FNota.TotalPago, 0);
end;

function TNotaController.Emitir: TResultadoOperacao;
begin
  Result := FService.Emitir(FNota);
end;

procedure TNotaController.Imprimir;
begin
  FService.Imprimir(FNota.Id);
end;

end.
