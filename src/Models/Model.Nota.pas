unit Model.Nota;

interface

uses
  System.Generics.Collections, Model.Tipos, Model.ItemNota, Model.Pagamento;

type
  TNota = class
  private
    FId: Integer;
    FModelo: TModeloNota;
    FSerie: Integer;
    FNumero: Integer;
    FDataEmissao: TDateTime;
    FNaturezaOperacao: string;
    FClienteId: Integer;
    FNomeCliente: string;
    FCpfConsumidor: string;
    FStatus: TStatusNota;
    FContingencia: Boolean;
    FChave: string;
    FProtocolo: string;
    FCStat: Integer;
    FMotivo: string;
    FValorProdutos: Currency;
    FValorDesconto: Currency;
    FBaseICMS: Currency;
    FValorICMS: Currency;
    FValorPIS: Currency;
    FValorCOFINS: Currency;
    FValorTotal: Currency;
    FValorTroco: Currency;
    FArquivoXml: string;
    FObservacao: string;
    FPedidoApiId: Integer;
    FItens: TObjectList<TItemNota>;
    FPagamentos: TObjectList<TPagamentoNota>;
  public
    constructor Create;
    destructor Destroy; override;
    function TotalPago: Currency;
    function Editavel: Boolean;
    property Id: Integer read FId write FId;
    property Modelo: TModeloNota read FModelo write FModelo;
    property Serie: Integer read FSerie write FSerie;
    property Numero: Integer read FNumero write FNumero;
    property DataEmissao: TDateTime read FDataEmissao write FDataEmissao;
    property NaturezaOperacao: string read FNaturezaOperacao write FNaturezaOperacao;
    property ClienteId: Integer read FClienteId write FClienteId;
    // só para exibição (vem do JOIN na consulta)
    property NomeCliente: string read FNomeCliente write FNomeCliente;
    property CpfConsumidor: string read FCpfConsumidor write FCpfConsumidor;
    property Status: TStatusNota read FStatus write FStatus;
    property Contingencia: Boolean read FContingencia write FContingencia;
    property Chave: string read FChave write FChave;
    property Protocolo: string read FProtocolo write FProtocolo;
    property CStat: Integer read FCStat write FCStat;
    property Motivo: string read FMotivo write FMotivo;
    property ValorProdutos: Currency read FValorProdutos write FValorProdutos;
    property ValorDesconto: Currency read FValorDesconto write FValorDesconto;
    property BaseICMS: Currency read FBaseICMS write FBaseICMS;
    property ValorICMS: Currency read FValorICMS write FValorICMS;
    property ValorPIS: Currency read FValorPIS write FValorPIS;
    property ValorCOFINS: Currency read FValorCOFINS write FValorCOFINS;
    property ValorTotal: Currency read FValorTotal write FValorTotal;
    property ValorTroco: Currency read FValorTroco write FValorTroco;
    property ArquivoXml: string read FArquivoXml write FArquivoXml;
    property Observacao: string read FObservacao write FObservacao;
    // pedido da delphi-horse-api que originou a nota; 0 = nota digitada
    property PedidoApiId: Integer read FPedidoApiId write FPedidoApiId;
    property Itens: TObjectList<TItemNota> read FItens;
    property Pagamentos: TObjectList<TPagamentoNota> read FPagamentos;
  end;

  TFiltroNota = record
    DataInicial: TDate;
    DataFinal: TDate;
    Modelo: Integer;  // 0 = todos, 55 ou 65
    Status: Integer;  // -1 = todos, senão Ord(TStatusNota)
    Texto: string;    // número, chave ou nome do cliente
    class function Padrao: TFiltroNota; static;
  end;

implementation

uses
  System.SysUtils, System.DateUtils;

constructor TNota.Create;
begin
  inherited;
  FItens := TObjectList<TItemNota>.Create(True);
  FPagamentos := TObjectList<TPagamentoNota>.Create(True);
  FModelo := TModeloNota.NFe;
  FStatus := TStatusNota.Digitacao;
  FNaturezaOperacao := 'VENDA DE MERCADORIA';
  FDataEmissao := Now;
end;

destructor TNota.Destroy;
begin
  FPagamentos.Free;
  FItens.Free;
  inherited;
end;

function TNota.Editavel: Boolean;
begin
  // rejeitada pode ser corrigida e reenviada com o mesmo número
  Result := FStatus in [TStatusNota.Digitacao, TStatusNota.Rejeitada];
end;

function TNota.TotalPago: Currency;
var
  LPagamento: TPagamentoNota;
begin
  Result := 0;
  for LPagamento in FPagamentos do
    Result := Result + LPagamento.Valor;
end;

class function TFiltroNota.Padrao: TFiltroNota;
begin
  Result.DataInicial := StartOfTheMonth(Date);
  Result.DataFinal := Date;
  Result.Modelo := 0;
  Result.Status := -1;
  Result.Texto := '';
end;

end.
