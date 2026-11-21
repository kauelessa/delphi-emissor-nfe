unit Model.FormaPagamento;

interface

type
  TFormaPagamento = class
  private
    FId: Integer;
    FDescricao: string;
    FCodigoSefaz: string;
    FAtivo: Boolean;
  public
    constructor Create;
    property Id: Integer read FId write FId;
    property Descricao: string read FDescricao write FDescricao;
    property CodigoSefaz: string read FCodigoSefaz write FCodigoSefaz;
    property Ativo: Boolean read FAtivo write FAtivo;
  end;

const
  // tabela tPag da NF-e (layout 4.00), só as mais usadas no varejo
  FORMAS_PAGAMENTO_SEFAZ: array[0..9] of array[0..1] of string = (
    ('01', 'Dinheiro'),
    ('02', 'Cheque'),
    ('03', 'Cartão de crédito'),
    ('04', 'Cartão de débito'),
    ('05', 'Crédito loja'),
    ('10', 'Vale alimentação'),
    ('11', 'Vale refeição'),
    ('15', 'Boleto bancário'),
    ('17', 'PIX'),
    ('99', 'Outros'));

implementation

constructor TFormaPagamento.Create;
begin
  inherited;
  FCodigoSefaz := '01';
  FAtivo := True;
end;

end.
