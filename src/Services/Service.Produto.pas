unit Service.Produto;

interface

uses
  System.Generics.Collections, Model.Produto, Repository.Produto;

type
  IProdutoService = interface
    ['{5E6F7A8B-9C0D-4E1F-2A3B-4C5D6E7F8091}']
    function Listar(const AFiltro: string): TObjectList<TProduto>;
    function Obter(AId: Integer): TProduto;
    procedure Salvar(AProduto: TProduto);
    procedure Inativar(AId: Integer);
  end;

  TProdutoService = class(TInterfacedObject, IProdutoService)
  private
    FRepo: IProdutoRepository;
  public
    constructor Create(ARepo: IProdutoRepository);
    function Listar(const AFiltro: string): TObjectList<TProduto>;
    function Obter(AId: Integer): TProduto;
    procedure Salvar(AProduto: TProduto);
    procedure Inativar(AId: Integer);
  end;

implementation

uses
  System.SysUtils, Model.Tipos, Infra.Documento;

constructor TProdutoService.Create(ARepo: IProdutoRepository);
begin
  inherited Create;
  FRepo := ARepo;
end;

function TProdutoService.Listar(const AFiltro: string): TObjectList<TProduto>;
begin
  Result := FRepo.Listar(AFiltro);
end;

function TProdutoService.Obter(AId: Integer): TProduto;
begin
  Result := FRepo.Obter(AId);
end;

procedure TProdutoService.Salvar(AProduto: TProduto);
var
  LExistente: TProduto;
begin
  AProduto.Codigo := Trim(AProduto.Codigo);
  AProduto.Descricao := Trim(AProduto.Descricao);
  AProduto.NCM := SoNumeros(AProduto.NCM);
  AProduto.CEST := SoNumeros(AProduto.CEST);
  AProduto.CFOP := SoNumeros(AProduto.CFOP);
  AProduto.Unidade := UpperCase(Trim(AProduto.Unidade));
  if Trim(AProduto.EAN) = '' then
    AProduto.EAN := 'SEM GTIN';

  if AProduto.Codigo = '' then
    raise EValidacao.Create('Informe o código');
  if Length(AProduto.Descricao) < 2 then
    raise EValidacao.Create('Informe a descrição');
  if Length(AProduto.NCM) <> 8 then
    raise EValidacao.Create('NCM deve ter 8 dígitos');
  if (AProduto.CEST <> '') and (Length(AProduto.CEST) <> 7) then
    raise EValidacao.Create('CEST deve ter 7 dígitos');
  if (Length(AProduto.CFOP) <> 4) or not CharInSet(AProduto.CFOP[1], ['5', '6']) then
    raise EValidacao.Create('CFOP de saída deve ter 4 dígitos e começar com 5 ou 6');
  if AProduto.Unidade = '' then
    raise EValidacao.Create('Informe a unidade');
  if AProduto.Preco <= 0 then
    raise EValidacao.Create('Preço deve ser maior que zero');
  if not GtinValido(AProduto.EAN) then
    raise EValidacao.Create('GTIN/EAN inválido (use SEM GTIN se o produto não tiver código de barras)');
  if not (Length(AProduto.CstCsosn) in [2, 3]) then
    raise EValidacao.Create('Informe o CST (2 dígitos) ou CSOSN (3 dígitos)');
  if (AProduto.Origem < 0) or (AProduto.Origem > 8) then
    raise EValidacao.Create('Origem da mercadoria deve ser de 0 a 8');
  if (AProduto.AliquotaICMS < 0) or (AProduto.AliquotaICMS > 100) or
     (AProduto.ReducaoBaseICMS < 0) or (AProduto.ReducaoBaseICMS >= 100) then
    raise EValidacao.Create('Alíquota/redução de ICMS fora da faixa');

  LExistente := FRepo.ObterPorCodigo(AProduto.Codigo);
  try
    if (LExistente <> nil) and (LExistente.Id <> AProduto.Id) and SameText(LExistente.Codigo, AProduto.Codigo) then
      raise EValidacao.CreateFmt('Já existe produto com o código %s', [AProduto.Codigo]);
  finally
    LExistente.Free;
  end;

  FRepo.Salvar(AProduto);
end;

procedure TProdutoService.Inativar(AId: Integer);
begin
  FRepo.Inativar(AId);
end;

end.
