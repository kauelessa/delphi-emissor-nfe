unit Repository.Produto;

interface

uses
  System.Generics.Collections, Model.Produto, Infra.Conexao;

type
  IProdutoRepository = interface
    ['{C5E3B2F4-AD90-4077-9E43-3F4A5B6C7D82}']
    function Listar(const AFiltro: string): TObjectList<TProduto>;
    function Obter(AId: Integer): TProduto;
    function ObterPorCodigo(const ACodigo: string): TProduto;
    procedure Salvar(AProduto: TProduto);
    procedure Inativar(AId: Integer);
  end;

  TProdutoRepository = class(TInterfacedObject, IProdutoRepository)
  private
    FConexao: IConexao;
    function ObterPor(const ASql: string; const AValor: Variant): TProduto;
  public
    constructor Create(AConexao: IConexao);
    function Listar(const AFiltro: string): TObjectList<TProduto>;
    function Obter(AId: Integer): TProduto;
    function ObterPorCodigo(const ACodigo: string): TProduto;
    procedure Salvar(AProduto: TProduto);
    procedure Inativar(AId: Integer);
  end;

implementation

uses
  System.SysUtils, Data.DB, FireDAC.Comp.Client, FireDAC.Stan.Param;

function LerProduto(AQry: TDataSet): TProduto;
begin
  Result := TProduto.Create;
  Result.Id := AQry.FieldByName('ID').AsInteger;
  Result.Codigo := AQry.FieldByName('CODIGO').AsString;
  Result.Descricao := AQry.FieldByName('DESCRICAO').AsString;
  Result.EAN := AQry.FieldByName('EAN').AsString;
  Result.NCM := AQry.FieldByName('NCM').AsString;
  Result.CEST := AQry.FieldByName('CEST').AsString;
  Result.CFOP := AQry.FieldByName('CFOP').AsString;
  Result.Unidade := AQry.FieldByName('UNIDADE').AsString;
  Result.Preco := AQry.FieldByName('PRECO').AsCurrency;
  Result.Origem := AQry.FieldByName('ORIGEM').AsInteger;
  Result.CstCsosn := AQry.FieldByName('CST_CSOSN').AsString;
  Result.AliquotaICMS := AQry.FieldByName('ALIQUOTA_ICMS').AsCurrency;
  Result.ReducaoBaseICMS := AQry.FieldByName('REDUCAO_BC_ICMS').AsCurrency;
  Result.CstPIS := AQry.FieldByName('CST_PIS').AsString;
  Result.AliquotaPIS := AQry.FieldByName('ALIQUOTA_PIS').AsCurrency;
  Result.CstCOFINS := AQry.FieldByName('CST_COFINS').AsString;
  Result.AliquotaCOFINS := AQry.FieldByName('ALIQUOTA_COFINS').AsCurrency;
  Result.Ativo := AQry.FieldByName('ATIVO').AsBoolean;
end;

constructor TProdutoRepository.Create(AConexao: IConexao);
begin
  inherited Create;
  FConexao := AConexao;
end;

function TProdutoRepository.Listar(const AFiltro: string): TObjectList<TProduto>;
var
  LQry: TFDQuery;
begin
  Result := TObjectList<TProduto>.Create;
  try
    LQry := FConexao.NovaQuery;
    try
      if Trim(AFiltro) = '' then
        LQry.SQL.Text := 'SELECT * FROM PRODUTO WHERE ATIVO = TRUE ORDER BY DESCRICAO'
      else
      begin
        LQry.SQL.Text := 'SELECT * FROM PRODUTO WHERE ATIVO = TRUE AND (CODIGO = :FILTRO ' +
          'OR EAN = :FILTRO OR UPPER(DESCRICAO) CONTAINING UPPER(:FILTRO)) ORDER BY DESCRICAO';
        LQry.ParamByName('FILTRO').AsString := Trim(AFiltro);
      end;
      LQry.Open;
      while not LQry.Eof do
      begin
        Result.Add(LerProduto(LQry));
        LQry.Next;
      end;
    finally
      LQry.Free;
    end;
  except
    Result.Free;
    raise;
  end;
end;

function TProdutoRepository.ObterPor(const ASql: string; const AValor: Variant): TProduto;
var
  LQry: TFDQuery;
begin
  LQry := FConexao.NovaQuery;
  try
    LQry.Open(ASql, [AValor]);
    if LQry.IsEmpty then
      Result := nil
    else
      Result := LerProduto(LQry);
  finally
    LQry.Free;
  end;
end;

function TProdutoRepository.Obter(AId: Integer): TProduto;
begin
  Result := ObterPor('SELECT * FROM PRODUTO WHERE ID = :ID', AId);
end;

function TProdutoRepository.ObterPorCodigo(const ACodigo: string): TProduto;
begin
  // aceita código interno ou o EAN lido no leitor de código de barras
  Result := ObterPor('SELECT FIRST 1 * FROM PRODUTO WHERE ATIVO = TRUE AND ' +
    '(CODIGO = :COD OR EAN = :COD)', Trim(ACodigo));
end;

procedure TProdutoRepository.Salvar(AProduto: TProduto);
var
  LQry: TFDQuery;
begin
  LQry := FConexao.NovaQuery;
  try
    if AProduto.Id = 0 then
      LQry.SQL.Text :=
        'INSERT INTO PRODUTO (CODIGO, DESCRICAO, EAN, NCM, CEST, CFOP, UNIDADE, PRECO, ORIGEM, ' +
        '  CST_CSOSN, ALIQUOTA_ICMS, REDUCAO_BC_ICMS, CST_PIS, ALIQUOTA_PIS, CST_COFINS, ' +
        '  ALIQUOTA_COFINS, ATIVO) ' +
        'VALUES (:CODIGO, :DESCRICAO, :EAN, :NCM, :CEST, :CFOP, :UNIDADE, :PRECO, :ORIGEM, ' +
        '  :CST_CSOSN, :ALIQUOTA_ICMS, :REDUCAO_BC_ICMS, :CST_PIS, :ALIQUOTA_PIS, :CST_COFINS, ' +
        '  :ALIQUOTA_COFINS, :ATIVO) RETURNING ID'
    else
      LQry.SQL.Text :=
        'UPDATE PRODUTO SET CODIGO = :CODIGO, DESCRICAO = :DESCRICAO, EAN = :EAN, NCM = :NCM, ' +
        '  CEST = :CEST, CFOP = :CFOP, UNIDADE = :UNIDADE, PRECO = :PRECO, ORIGEM = :ORIGEM, ' +
        '  CST_CSOSN = :CST_CSOSN, ALIQUOTA_ICMS = :ALIQUOTA_ICMS, ' +
        '  REDUCAO_BC_ICMS = :REDUCAO_BC_ICMS, CST_PIS = :CST_PIS, ALIQUOTA_PIS = :ALIQUOTA_PIS, ' +
        '  CST_COFINS = :CST_COFINS, ALIQUOTA_COFINS = :ALIQUOTA_COFINS, ATIVO = :ATIVO ' +
        'WHERE ID = :ID RETURNING ID';

    LQry.ParamByName('CODIGO').AsString := AProduto.Codigo;
    LQry.ParamByName('DESCRICAO').AsString := AProduto.Descricao;
    LQry.ParamByName('EAN').AsString := AProduto.EAN;
    LQry.ParamByName('NCM').AsString := AProduto.NCM;
    LQry.ParamByName('CEST').AsString := AProduto.CEST;
    LQry.ParamByName('CFOP').AsString := AProduto.CFOP;
    LQry.ParamByName('UNIDADE').AsString := AProduto.Unidade;
    LQry.ParamByName('PRECO').AsCurrency := AProduto.Preco;
    LQry.ParamByName('ORIGEM').AsInteger := AProduto.Origem;
    LQry.ParamByName('CST_CSOSN').AsString := AProduto.CstCsosn;
    LQry.ParamByName('ALIQUOTA_ICMS').AsCurrency := AProduto.AliquotaICMS;
    LQry.ParamByName('REDUCAO_BC_ICMS').AsCurrency := AProduto.ReducaoBaseICMS;
    LQry.ParamByName('CST_PIS').AsString := AProduto.CstPIS;
    LQry.ParamByName('ALIQUOTA_PIS').AsCurrency := AProduto.AliquotaPIS;
    LQry.ParamByName('CST_COFINS').AsString := AProduto.CstCOFINS;
    LQry.ParamByName('ALIQUOTA_COFINS').AsCurrency := AProduto.AliquotaCOFINS;
    LQry.ParamByName('ATIVO').AsBoolean := AProduto.Ativo;
    if AProduto.Id > 0 then
      LQry.ParamByName('ID').AsInteger := AProduto.Id;

    LQry.Open;
    AProduto.Id := LQry.FieldByName('ID').AsInteger;
  finally
    LQry.Free;
  end;
end;

procedure TProdutoRepository.Inativar(AId: Integer);
begin
  FConexao.Connection.ExecSQL('UPDATE PRODUTO SET ATIVO = FALSE WHERE ID = :ID', [AId]);
end;

end.
