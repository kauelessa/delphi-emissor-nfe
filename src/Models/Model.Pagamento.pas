unit Model.Pagamento;

interface

type
  TPagamentoNota = class
  private
    FFormaPagamentoId: Integer;
    FCodigoSefaz: string;
    FDescricao: string;
    FValor: Currency;
  public
    property FormaPagamentoId: Integer read FFormaPagamentoId write FFormaPagamentoId;
    property CodigoSefaz: string read FCodigoSefaz write FCodigoSefaz;
    property Descricao: string read FDescricao write FDescricao;
    property Valor: Currency read FValor write FValor;
  end;

implementation

end.
