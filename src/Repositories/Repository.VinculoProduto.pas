unit Repository.VinculoProduto;

interface

uses
  Infra.Conexao;

type
  IVinculoProdutoRepository = interface
    ['{3C9A7E21-5B4D-4F8A-9D61-7E2B0C4A8F15}']
    function ProdutoDoEmissor(AApiProdutoId: Integer): Integer;
    procedure Gravar(AApiProdutoId, AProdutoId: Integer);
  end;

  TVinculoProdutoRepository = class(TInterfacedObject, IVinculoProdutoRepository)
  private
    FConexao: IConexao;
  public
    constructor Create(AConexao: IConexao);
    function ProdutoDoEmissor(AApiProdutoId: Integer): Integer;
    procedure Gravar(AApiProdutoId, AProdutoId: Integer);
  end;

implementation

uses
  System.Variants;

constructor TVinculoProdutoRepository.Create(AConexao: IConexao);
begin
  inherited Create;
  FConexao := AConexao;
end;

function TVinculoProdutoRepository.ProdutoDoEmissor(AApiProdutoId: Integer): Integer;
var
  LId: Variant;
begin
  LId := FConexao.Connection.ExecSQLScalar(
    'SELECT PRODUTO_ID FROM PRODUTO_VINCULO_API WHERE API_PRODUTO_ID = :ID', [AApiProdutoId]);
  if VarIsNull(LId) or VarIsEmpty(LId) then
    Result := 0
  else
    Result := LId;
end;

procedure TVinculoProdutoRepository.Gravar(AApiProdutoId, AProdutoId: Integer);
begin
  // revincular (produto antigo inativado) só troca o PRODUTO_ID
  FConexao.Connection.ExecSQL(
    'UPDATE OR INSERT INTO PRODUTO_VINCULO_API (API_PRODUTO_ID, PRODUTO_ID) ' +
    'VALUES (:API_ID, :PRODUTO_ID) MATCHING (API_PRODUTO_ID)', [AApiProdutoId, AProdutoId]);
end;

end.
