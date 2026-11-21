unit Model.Produto;

interface

type
  TProduto = class
  private
    FId: Integer;
    FCodigo: string;
    FDescricao: string;
    FEAN: string;
    FNCM: string;
    FCEST: string;
    FCFOP: string;
    FUnidade: string;
    FPreco: Currency;
    FOrigem: Integer;
    FCstCsosn: string;
    FAliquotaICMS: Currency;
    FReducaoBaseICMS: Currency;
    FCstPIS: string;
    FAliquotaPIS: Currency;
    FCstCOFINS: string;
    FAliquotaCOFINS: Currency;
    FAtivo: Boolean;
  public
    constructor Create;
    property Id: Integer read FId write FId;
    property Codigo: string read FCodigo write FCodigo;
    property Descricao: string read FDescricao write FDescricao;
    property EAN: string read FEAN write FEAN;
    property NCM: string read FNCM write FNCM;
    property CEST: string read FCEST write FCEST;
    property CFOP: string read FCFOP write FCFOP;
    property Unidade: string read FUnidade write FUnidade;
    property Preco: Currency read FPreco write FPreco;
    property Origem: Integer read FOrigem write FOrigem;
    // 2 dígitos = CST (regime normal), 3 dígitos = CSOSN (Simples)
    property CstCsosn: string read FCstCsosn write FCstCsosn;
    property AliquotaICMS: Currency read FAliquotaICMS write FAliquotaICMS;
    property ReducaoBaseICMS: Currency read FReducaoBaseICMS write FReducaoBaseICMS;
    property CstPIS: string read FCstPIS write FCstPIS;
    property AliquotaPIS: Currency read FAliquotaPIS write FAliquotaPIS;
    property CstCOFINS: string read FCstCOFINS write FCstCOFINS;
    property AliquotaCOFINS: Currency read FAliquotaCOFINS write FAliquotaCOFINS;
    property Ativo: Boolean read FAtivo write FAtivo;
  end;

implementation

constructor TProduto.Create;
begin
  inherited;
  FEAN := 'SEM GTIN';
  FUnidade := 'UN';
  FCFOP := '5102';
  FCstCsosn := '102';
  FCstPIS := '49';
  FCstCOFINS := '49';
  FAtivo := True;
end;

end.
