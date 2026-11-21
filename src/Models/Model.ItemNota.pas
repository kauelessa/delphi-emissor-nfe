unit Model.ItemNota;

interface

uses
  Model.Produto;

type
  // os dados fiscais do produto são copiados para o item no momento da venda,
  // assim alterar o cadastro depois não mexe em nota já emitida
  TItemNota = class
  private
    FNumeroItem: Integer;
    FProdutoId: Integer;
    FCodigo: string;
    FDescricao: string;
    FEAN: string;
    FNCM: string;
    FCEST: string;
    FCFOP: string;
    FUnidade: string;
    FQuantidade: Currency;
    FValorUnitario: Currency;
    FValorProduto: Currency;
    FValorDesconto: Currency;
    FOrigem: Integer;
    FCstCsosn: string;
    FAliquotaICMS: Currency;
    FReducaoBaseICMS: Currency;
    FBaseICMS: Currency;
    FValorICMS: Currency;
    FCstPIS: string;
    FAliquotaPIS: Currency;
    FBasePIS: Currency;
    FValorPIS: Currency;
    FCstCOFINS: string;
    FAliquotaCOFINS: Currency;
    FBaseCOFINS: Currency;
    FValorCOFINS: Currency;
    FValorTotal: Currency;
  public
    procedure CopiarProduto(AProduto: TProduto);
    property NumeroItem: Integer read FNumeroItem write FNumeroItem;
    property ProdutoId: Integer read FProdutoId write FProdutoId;
    property Codigo: string read FCodigo write FCodigo;
    property Descricao: string read FDescricao write FDescricao;
    property EAN: string read FEAN write FEAN;
    property NCM: string read FNCM write FNCM;
    property CEST: string read FCEST write FCEST;
    property CFOP: string read FCFOP write FCFOP;
    property Unidade: string read FUnidade write FUnidade;
    property Quantidade: Currency read FQuantidade write FQuantidade;
    property ValorUnitario: Currency read FValorUnitario write FValorUnitario;
    property ValorProduto: Currency read FValorProduto write FValorProduto;
    property ValorDesconto: Currency read FValorDesconto write FValorDesconto;
    property Origem: Integer read FOrigem write FOrigem;
    property CstCsosn: string read FCstCsosn write FCstCsosn;
    property AliquotaICMS: Currency read FAliquotaICMS write FAliquotaICMS;
    property ReducaoBaseICMS: Currency read FReducaoBaseICMS write FReducaoBaseICMS;
    property BaseICMS: Currency read FBaseICMS write FBaseICMS;
    property ValorICMS: Currency read FValorICMS write FValorICMS;
    property CstPIS: string read FCstPIS write FCstPIS;
    property AliquotaPIS: Currency read FAliquotaPIS write FAliquotaPIS;
    property BasePIS: Currency read FBasePIS write FBasePIS;
    property ValorPIS: Currency read FValorPIS write FValorPIS;
    property CstCOFINS: string read FCstCOFINS write FCstCOFINS;
    property AliquotaCOFINS: Currency read FAliquotaCOFINS write FAliquotaCOFINS;
    property BaseCOFINS: Currency read FBaseCOFINS write FBaseCOFINS;
    property ValorCOFINS: Currency read FValorCOFINS write FValorCOFINS;
    property ValorTotal: Currency read FValorTotal write FValorTotal;
  end;

implementation

procedure TItemNota.CopiarProduto(AProduto: TProduto);
begin
  FProdutoId := AProduto.Id;
  FCodigo := AProduto.Codigo;
  FDescricao := AProduto.Descricao;
  FEAN := AProduto.EAN;
  FNCM := AProduto.NCM;
  FCEST := AProduto.CEST;
  FCFOP := AProduto.CFOP;
  FUnidade := AProduto.Unidade;
  FValorUnitario := AProduto.Preco;
  FOrigem := AProduto.Origem;
  FCstCsosn := AProduto.CstCsosn;
  FAliquotaICMS := AProduto.AliquotaICMS;
  FReducaoBaseICMS := AProduto.ReducaoBaseICMS;
  FCstPIS := AProduto.CstPIS;
  FAliquotaPIS := AProduto.AliquotaPIS;
  FCstCOFINS := AProduto.CstCOFINS;
  FAliquotaCOFINS := AProduto.AliquotaCOFINS;
end;

end.
