unit Repository.Nota;

interface

uses
  System.Generics.Collections, Model.Nota, Infra.Conexao;

type
  INotaRepository = interface
    ['{E7A5D4B6-CFB2-4299-B065-5B6C7D8E9FA4}']
    procedure Salvar(ANota: TNota);
    procedure AtualizarSituacao(ANota: TNota);
    function Obter(AId: Integer): TNota;
    function Listar(const AFiltro: TFiltroNota): TObjectList<TNota>;
    function ObterFaturadaDoPedido(APedidoApiId: Integer): TNota;
  end;

  TNotaRepository = class(TInterfacedObject, INotaRepository)
  private
    FConexao: IConexao;
    procedure GravarCabecalho(ANota: TNota);
    procedure GravarItens(ANota: TNota);
    procedure GravarPagamentos(ANota: TNota);
    procedure CarregarItens(ANota: TNota);
    procedure CarregarPagamentos(ANota: TNota);
  public
    constructor Create(AConexao: IConexao);
    procedure Salvar(ANota: TNota);
    procedure AtualizarSituacao(ANota: TNota);
    function Obter(AId: Integer): TNota;
    function Listar(const AFiltro: TFiltroNota): TObjectList<TNota>;
    function ObterFaturadaDoPedido(APedidoApiId: Integer): TNota;
  end;

implementation

uses
  System.SysUtils, System.DateUtils, Data.DB, FireDAC.Comp.Client, FireDAC.Stan.Param,
  Model.Tipos, Model.ItemNota, Model.Pagamento;

// número/chave/cliente vazios vão como NULL (as constraints UNIQUE dependem disso)
procedure ParamInteiroOuNulo(AParam: TFDParam; AValor: Integer);
begin
  AParam.DataType := ftInteger;
  if AValor > 0 then
    AParam.AsInteger := AValor
  else
    AParam.Clear;
end;

procedure ParamTextoOuNulo(AParam: TFDParam; const AValor: string);
begin
  AParam.DataType := ftString;
  if AValor <> '' then
    AParam.AsString := AValor
  else
    AParam.Clear;
end;

function LerCabecalho(AQry: TDataSet): TNota;
begin
  Result := TNota.Create;
  Result.Id := AQry.FieldByName('ID').AsInteger;
  Result.Modelo := TModeloNota.DeCodigo(AQry.FieldByName('MODELO').AsInteger);
  Result.Serie := AQry.FieldByName('SERIE').AsInteger;
  Result.Numero := AQry.FieldByName('NUMERO').AsInteger;
  Result.DataEmissao := AQry.FieldByName('DATA_EMISSAO').AsDateTime;
  Result.NaturezaOperacao := AQry.FieldByName('NATUREZA_OPERACAO').AsString;
  Result.ClienteId := AQry.FieldByName('CLIENTE_ID').AsInteger;
  Result.NomeCliente := AQry.FieldByName('NOME_CLIENTE').AsString;
  Result.CpfConsumidor := AQry.FieldByName('CPF_CONSUMIDOR').AsString;
  Result.Status := TStatusNota(AQry.FieldByName('STATUS').AsInteger);
  Result.Contingencia := AQry.FieldByName('CONTINGENCIA').AsBoolean;
  Result.Chave := AQry.FieldByName('CHAVE').AsString;
  Result.Protocolo := AQry.FieldByName('PROTOCOLO').AsString;
  Result.CStat := AQry.FieldByName('CSTAT').AsInteger;
  Result.Motivo := AQry.FieldByName('MOTIVO').AsString;
  Result.ValorProdutos := AQry.FieldByName('VALOR_PRODUTOS').AsCurrency;
  Result.ValorDesconto := AQry.FieldByName('VALOR_DESCONTO').AsCurrency;
  Result.BaseICMS := AQry.FieldByName('BASE_ICMS').AsCurrency;
  Result.ValorICMS := AQry.FieldByName('VALOR_ICMS').AsCurrency;
  Result.ValorPIS := AQry.FieldByName('VALOR_PIS').AsCurrency;
  Result.ValorCOFINS := AQry.FieldByName('VALOR_COFINS').AsCurrency;
  Result.ValorTotal := AQry.FieldByName('VALOR_TOTAL').AsCurrency;
  Result.ValorTroco := AQry.FieldByName('VALOR_TROCO').AsCurrency;
  Result.ArquivoXml := AQry.FieldByName('ARQUIVO_XML').AsString;
  Result.Observacao := AQry.FieldByName('OBSERVACAO').AsString;
  Result.PedidoApiId := AQry.FieldByName('PEDIDO_API_ID').AsInteger;
end;

const
  SQL_SELECT_NOTA =
    'SELECT N.*, C.NOME AS NOME_CLIENTE FROM NOTA N ' +
    'LEFT JOIN CLIENTE C ON C.ID = N.CLIENTE_ID ';

{ TNotaRepository }

constructor TNotaRepository.Create(AConexao: IConexao);
begin
  inherited Create;
  FConexao := AConexao;
end;

procedure TNotaRepository.Salvar(ANota: TNota);
begin
  FConexao.Connection.StartTransaction;
  try
    GravarCabecalho(ANota);
    GravarItens(ANota);
    GravarPagamentos(ANota);
    FConexao.Connection.Commit;
  except
    FConexao.Connection.Rollback;
    raise;
  end;
end;

procedure TNotaRepository.GravarCabecalho(ANota: TNota);
var
  LQry: TFDQuery;
begin
  LQry := FConexao.NovaQuery;
  try
    if ANota.Id = 0 then
      LQry.SQL.Text :=
        'INSERT INTO NOTA (MODELO, SERIE, NUMERO, DATA_EMISSAO, NATUREZA_OPERACAO, CLIENTE_ID, ' +
        '  CPF_CONSUMIDOR, STATUS, CONTINGENCIA, CHAVE, PROTOCOLO, CSTAT, MOTIVO, VALOR_PRODUTOS, ' +
        '  VALOR_DESCONTO, BASE_ICMS, VALOR_ICMS, VALOR_PIS, VALOR_COFINS, VALOR_TOTAL, ' +
        '  VALOR_TROCO, ARQUIVO_XML, OBSERVACAO, PEDIDO_API_ID) ' +
        'VALUES (:MODELO, :SERIE, :NUMERO, :DATA_EMISSAO, :NATUREZA_OPERACAO, :CLIENTE_ID, ' +
        '  :CPF_CONSUMIDOR, :STATUS, :CONTINGENCIA, :CHAVE, :PROTOCOLO, :CSTAT, :MOTIVO, ' +
        '  :VALOR_PRODUTOS, :VALOR_DESCONTO, :BASE_ICMS, :VALOR_ICMS, :VALOR_PIS, :VALOR_COFINS, ' +
        '  :VALOR_TOTAL, :VALOR_TROCO, :ARQUIVO_XML, :OBSERVACAO, :PEDIDO_API_ID) RETURNING ID'
    else
      LQry.SQL.Text :=
        'UPDATE NOTA SET MODELO = :MODELO, SERIE = :SERIE, NUMERO = :NUMERO, ' +
        '  DATA_EMISSAO = :DATA_EMISSAO, NATUREZA_OPERACAO = :NATUREZA_OPERACAO, ' +
        '  CLIENTE_ID = :CLIENTE_ID, CPF_CONSUMIDOR = :CPF_CONSUMIDOR, STATUS = :STATUS, ' +
        '  CONTINGENCIA = :CONTINGENCIA, CHAVE = :CHAVE, PROTOCOLO = :PROTOCOLO, CSTAT = :CSTAT, ' +
        '  MOTIVO = :MOTIVO, VALOR_PRODUTOS = :VALOR_PRODUTOS, VALOR_DESCONTO = :VALOR_DESCONTO, ' +
        '  BASE_ICMS = :BASE_ICMS, VALOR_ICMS = :VALOR_ICMS, VALOR_PIS = :VALOR_PIS, ' +
        '  VALOR_COFINS = :VALOR_COFINS, VALOR_TOTAL = :VALOR_TOTAL, VALOR_TROCO = :VALOR_TROCO, ' +
        '  ARQUIVO_XML = :ARQUIVO_XML, OBSERVACAO = :OBSERVACAO, PEDIDO_API_ID = :PEDIDO_API_ID ' +
        'WHERE ID = :ID RETURNING ID';

    LQry.ParamByName('MODELO').AsInteger := ANota.Modelo.Codigo;
    LQry.ParamByName('SERIE').AsInteger := ANota.Serie;
    ParamInteiroOuNulo(LQry.ParamByName('NUMERO'), ANota.Numero);
    LQry.ParamByName('DATA_EMISSAO').AsDateTime := ANota.DataEmissao;
    LQry.ParamByName('NATUREZA_OPERACAO').AsString := ANota.NaturezaOperacao;
    ParamInteiroOuNulo(LQry.ParamByName('CLIENTE_ID'), ANota.ClienteId);
    ParamTextoOuNulo(LQry.ParamByName('CPF_CONSUMIDOR'), ANota.CpfConsumidor);
    LQry.ParamByName('STATUS').AsInteger := Ord(ANota.Status);
    LQry.ParamByName('CONTINGENCIA').AsBoolean := ANota.Contingencia;
    ParamTextoOuNulo(LQry.ParamByName('CHAVE'), ANota.Chave);
    ParamTextoOuNulo(LQry.ParamByName('PROTOCOLO'), ANota.Protocolo);
    ParamInteiroOuNulo(LQry.ParamByName('CSTAT'), ANota.CStat);
    ParamTextoOuNulo(LQry.ParamByName('MOTIVO'), Copy(ANota.Motivo, 1, 255));
    LQry.ParamByName('VALOR_PRODUTOS').AsCurrency := ANota.ValorProdutos;
    LQry.ParamByName('VALOR_DESCONTO').AsCurrency := ANota.ValorDesconto;
    LQry.ParamByName('BASE_ICMS').AsCurrency := ANota.BaseICMS;
    LQry.ParamByName('VALOR_ICMS').AsCurrency := ANota.ValorICMS;
    LQry.ParamByName('VALOR_PIS').AsCurrency := ANota.ValorPIS;
    LQry.ParamByName('VALOR_COFINS').AsCurrency := ANota.ValorCOFINS;
    LQry.ParamByName('VALOR_TOTAL').AsCurrency := ANota.ValorTotal;
    LQry.ParamByName('VALOR_TROCO').AsCurrency := ANota.ValorTroco;
    ParamTextoOuNulo(LQry.ParamByName('ARQUIVO_XML'), ANota.ArquivoXml);
    ParamTextoOuNulo(LQry.ParamByName('OBSERVACAO'), ANota.Observacao);
    ParamInteiroOuNulo(LQry.ParamByName('PEDIDO_API_ID'), ANota.PedidoApiId);
    if ANota.Id > 0 then
      LQry.ParamByName('ID').AsInteger := ANota.Id;

    LQry.Open;
    ANota.Id := LQry.FieldByName('ID').AsInteger;
  finally
    LQry.Free;
  end;
end;

procedure TNotaRepository.GravarItens(ANota: TNota);
var
  LQry: TFDQuery;
  LItem: TItemNota;
begin
  // itens são regravados inteiros: nota em digitação muda o tempo todo
  FConexao.Connection.ExecSQL('DELETE FROM NOTA_ITEM WHERE NOTA_ID = :ID', [ANota.Id]);

  LQry := FConexao.NovaQuery;
  try
    LQry.SQL.Text :=
      'INSERT INTO NOTA_ITEM (NOTA_ID, NUMERO_ITEM, PRODUTO_ID, CODIGO, DESCRICAO, EAN, NCM, ' +
      '  CEST, CFOP, UNIDADE, QUANTIDADE, VALOR_UNITARIO, VALOR_PRODUTO, VALOR_DESCONTO, ' +
      '  ORIGEM, CST_CSOSN, ALIQUOTA_ICMS, REDUCAO_BC_ICMS, BASE_ICMS, VALOR_ICMS, CST_PIS, ' +
      '  ALIQUOTA_PIS, BASE_PIS, VALOR_PIS, CST_COFINS, ALIQUOTA_COFINS, BASE_COFINS, ' +
      '  VALOR_COFINS, VALOR_TOTAL) ' +
      'VALUES (:NOTA_ID, :NUMERO_ITEM, :PRODUTO_ID, :CODIGO, :DESCRICAO, :EAN, :NCM, ' +
      '  :CEST, :CFOP, :UNIDADE, :QUANTIDADE, :VALOR_UNITARIO, :VALOR_PRODUTO, :VALOR_DESCONTO, ' +
      '  :ORIGEM, :CST_CSOSN, :ALIQUOTA_ICMS, :REDUCAO_BC_ICMS, :BASE_ICMS, :VALOR_ICMS, :CST_PIS, ' +
      '  :ALIQUOTA_PIS, :BASE_PIS, :VALOR_PIS, :CST_COFINS, :ALIQUOTA_COFINS, :BASE_COFINS, ' +
      '  :VALOR_COFINS, :VALOR_TOTAL)';

    for LItem in ANota.Itens do
    begin
      LQry.ParamByName('NOTA_ID').AsInteger := ANota.Id;
      LQry.ParamByName('NUMERO_ITEM').AsInteger := LItem.NumeroItem;
      LQry.ParamByName('PRODUTO_ID').AsInteger := LItem.ProdutoId;
      LQry.ParamByName('CODIGO').AsString := LItem.Codigo;
      LQry.ParamByName('DESCRICAO').AsString := LItem.Descricao;
      LQry.ParamByName('EAN').AsString := LItem.EAN;
      LQry.ParamByName('NCM').AsString := LItem.NCM;
      LQry.ParamByName('CEST').AsString := LItem.CEST;
      LQry.ParamByName('CFOP').AsString := LItem.CFOP;
      LQry.ParamByName('UNIDADE').AsString := LItem.Unidade;
      LQry.ParamByName('QUANTIDADE').AsCurrency := LItem.Quantidade;
      LQry.ParamByName('VALOR_UNITARIO').AsCurrency := LItem.ValorUnitario;
      LQry.ParamByName('VALOR_PRODUTO').AsCurrency := LItem.ValorProduto;
      LQry.ParamByName('VALOR_DESCONTO').AsCurrency := LItem.ValorDesconto;
      LQry.ParamByName('ORIGEM').AsInteger := LItem.Origem;
      LQry.ParamByName('CST_CSOSN').AsString := LItem.CstCsosn;
      LQry.ParamByName('ALIQUOTA_ICMS').AsCurrency := LItem.AliquotaICMS;
      LQry.ParamByName('REDUCAO_BC_ICMS').AsCurrency := LItem.ReducaoBaseICMS;
      LQry.ParamByName('BASE_ICMS').AsCurrency := LItem.BaseICMS;
      LQry.ParamByName('VALOR_ICMS').AsCurrency := LItem.ValorICMS;
      LQry.ParamByName('CST_PIS').AsString := LItem.CstPIS;
      LQry.ParamByName('ALIQUOTA_PIS').AsCurrency := LItem.AliquotaPIS;
      LQry.ParamByName('BASE_PIS').AsCurrency := LItem.BasePIS;
      LQry.ParamByName('VALOR_PIS').AsCurrency := LItem.ValorPIS;
      LQry.ParamByName('CST_COFINS').AsString := LItem.CstCOFINS;
      LQry.ParamByName('ALIQUOTA_COFINS').AsCurrency := LItem.AliquotaCOFINS;
      LQry.ParamByName('BASE_COFINS').AsCurrency := LItem.BaseCOFINS;
      LQry.ParamByName('VALOR_COFINS').AsCurrency := LItem.ValorCOFINS;
      LQry.ParamByName('VALOR_TOTAL').AsCurrency := LItem.ValorTotal;
      LQry.ExecSQL;
    end;
  finally
    LQry.Free;
  end;
end;

procedure TNotaRepository.GravarPagamentos(ANota: TNota);
var
  LQry: TFDQuery;
  LPagamento: TPagamentoNota;
begin
  FConexao.Connection.ExecSQL('DELETE FROM NOTA_PAGAMENTO WHERE NOTA_ID = :ID', [ANota.Id]);

  LQry := FConexao.NovaQuery;
  try
    LQry.SQL.Text := 'INSERT INTO NOTA_PAGAMENTO (NOTA_ID, FORMA_PAGAMENTO_ID, CODIGO_SEFAZ, ' +
      'DESCRICAO, VALOR) VALUES (:NOTA_ID, :FORMA_PAGAMENTO_ID, :CODIGO_SEFAZ, :DESCRICAO, :VALOR)';
    for LPagamento in ANota.Pagamentos do
    begin
      LQry.ParamByName('NOTA_ID').AsInteger := ANota.Id;
      LQry.ParamByName('FORMA_PAGAMENTO_ID').AsInteger := LPagamento.FormaPagamentoId;
      LQry.ParamByName('CODIGO_SEFAZ').AsString := LPagamento.CodigoSefaz;
      LQry.ParamByName('DESCRICAO').AsString := LPagamento.Descricao;
      LQry.ParamByName('VALOR').AsCurrency := LPagamento.Valor;
      LQry.ExecSQL;
    end;
  finally
    LQry.Free;
  end;
end;

procedure TNotaRepository.AtualizarSituacao(ANota: TNota);
var
  LQry: TFDQuery;
begin
  LQry := FConexao.NovaQuery;
  try
    LQry.SQL.Text :=
      'UPDATE NOTA SET STATUS = :STATUS, CONTINGENCIA = :CONTINGENCIA, CHAVE = :CHAVE, ' +
      '  PROTOCOLO = :PROTOCOLO, CSTAT = :CSTAT, MOTIVO = :MOTIVO, ARQUIVO_XML = :ARQUIVO_XML, ' +
      '  DATA_EMISSAO = :DATA_EMISSAO ' +
      'WHERE ID = :ID';
    LQry.ParamByName('STATUS').AsInteger := Ord(ANota.Status);
    LQry.ParamByName('CONTINGENCIA').AsBoolean := ANota.Contingencia;
    ParamTextoOuNulo(LQry.ParamByName('CHAVE'), ANota.Chave);
    ParamTextoOuNulo(LQry.ParamByName('PROTOCOLO'), ANota.Protocolo);
    ParamInteiroOuNulo(LQry.ParamByName('CSTAT'), ANota.CStat);
    ParamTextoOuNulo(LQry.ParamByName('MOTIVO'), Copy(ANota.Motivo, 1, 255));
    ParamTextoOuNulo(LQry.ParamByName('ARQUIVO_XML'), ANota.ArquivoXml);
    LQry.ParamByName('DATA_EMISSAO').AsDateTime := ANota.DataEmissao;
    LQry.ParamByName('ID').AsInteger := ANota.Id;
    LQry.ExecSQL;
  finally
    LQry.Free;
  end;
end;

procedure TNotaRepository.CarregarItens(ANota: TNota);
var
  LQry: TFDQuery;
  LItem: TItemNota;
begin
  LQry := FConexao.NovaQuery;
  try
    LQry.Open('SELECT * FROM NOTA_ITEM WHERE NOTA_ID = :ID ORDER BY NUMERO_ITEM', [ANota.Id]);
    while not LQry.Eof do
    begin
      LItem := TItemNota.Create;
      ANota.Itens.Add(LItem);
      LItem.NumeroItem := LQry.FieldByName('NUMERO_ITEM').AsInteger;
      LItem.ProdutoId := LQry.FieldByName('PRODUTO_ID').AsInteger;
      LItem.Codigo := LQry.FieldByName('CODIGO').AsString;
      LItem.Descricao := LQry.FieldByName('DESCRICAO').AsString;
      LItem.EAN := LQry.FieldByName('EAN').AsString;
      LItem.NCM := LQry.FieldByName('NCM').AsString;
      LItem.CEST := LQry.FieldByName('CEST').AsString;
      LItem.CFOP := LQry.FieldByName('CFOP').AsString;
      LItem.Unidade := LQry.FieldByName('UNIDADE').AsString;
      LItem.Quantidade := LQry.FieldByName('QUANTIDADE').AsCurrency;
      LItem.ValorUnitario := LQry.FieldByName('VALOR_UNITARIO').AsCurrency;
      LItem.ValorProduto := LQry.FieldByName('VALOR_PRODUTO').AsCurrency;
      LItem.ValorDesconto := LQry.FieldByName('VALOR_DESCONTO').AsCurrency;
      LItem.Origem := LQry.FieldByName('ORIGEM').AsInteger;
      LItem.CstCsosn := LQry.FieldByName('CST_CSOSN').AsString;
      LItem.AliquotaICMS := LQry.FieldByName('ALIQUOTA_ICMS').AsCurrency;
      LItem.ReducaoBaseICMS := LQry.FieldByName('REDUCAO_BC_ICMS').AsCurrency;
      LItem.BaseICMS := LQry.FieldByName('BASE_ICMS').AsCurrency;
      LItem.ValorICMS := LQry.FieldByName('VALOR_ICMS').AsCurrency;
      LItem.CstPIS := LQry.FieldByName('CST_PIS').AsString;
      LItem.AliquotaPIS := LQry.FieldByName('ALIQUOTA_PIS').AsCurrency;
      LItem.BasePIS := LQry.FieldByName('BASE_PIS').AsCurrency;
      LItem.ValorPIS := LQry.FieldByName('VALOR_PIS').AsCurrency;
      LItem.CstCOFINS := LQry.FieldByName('CST_COFINS').AsString;
      LItem.AliquotaCOFINS := LQry.FieldByName('ALIQUOTA_COFINS').AsCurrency;
      LItem.BaseCOFINS := LQry.FieldByName('BASE_COFINS').AsCurrency;
      LItem.ValorCOFINS := LQry.FieldByName('VALOR_COFINS').AsCurrency;
      LItem.ValorTotal := LQry.FieldByName('VALOR_TOTAL').AsCurrency;
      LQry.Next;
    end;
  finally
    LQry.Free;
  end;
end;

procedure TNotaRepository.CarregarPagamentos(ANota: TNota);
var
  LQry: TFDQuery;
  LPagamento: TPagamentoNota;
begin
  LQry := FConexao.NovaQuery;
  try
    LQry.Open('SELECT * FROM NOTA_PAGAMENTO WHERE NOTA_ID = :ID ORDER BY ID', [ANota.Id]);
    while not LQry.Eof do
    begin
      LPagamento := TPagamentoNota.Create;
      ANota.Pagamentos.Add(LPagamento);
      LPagamento.FormaPagamentoId := LQry.FieldByName('FORMA_PAGAMENTO_ID').AsInteger;
      LPagamento.CodigoSefaz := LQry.FieldByName('CODIGO_SEFAZ').AsString;
      LPagamento.Descricao := LQry.FieldByName('DESCRICAO').AsString;
      LPagamento.Valor := LQry.FieldByName('VALOR').AsCurrency;
      LQry.Next;
    end;
  finally
    LQry.Free;
  end;
end;

function TNotaRepository.Obter(AId: Integer): TNota;
var
  LQry: TFDQuery;
begin
  Result := nil;
  LQry := FConexao.NovaQuery;
  try
    LQry.Open(SQL_SELECT_NOTA + 'WHERE N.ID = :ID', [AId]);
    if not LQry.IsEmpty then
      Result := LerCabecalho(LQry);
  finally
    LQry.Free;
  end;

  if Result = nil then
    Exit;
  try
    CarregarItens(Result);
    CarregarPagamentos(Result);
  except
    Result.Free;
    raise;
  end;
end;

function TNotaRepository.ObterFaturadaDoPedido(APedidoApiId: Integer): TNota;
var
  LQry: TFDQuery;
begin
  // só autorizada ou em contingência conta como faturada; rejeitada/cancelada libera o pedido
  LQry := FConexao.NovaQuery;
  try
    LQry.Open(SQL_SELECT_NOTA +
      'WHERE N.PEDIDO_API_ID = :PEDIDO AND N.STATUS IN (:AUTORIZADA, :CONTINGENCIA) ' +
      'ORDER BY N.ID DESC ROWS 1',
      [APedidoApiId, Ord(TStatusNota.Autorizada), Ord(TStatusNota.Contingencia)]);
    if LQry.IsEmpty then
      Result := nil
    else
      Result := LerCabecalho(LQry);
  finally
    LQry.Free;
  end;
end;

function TNotaRepository.Listar(const AFiltro: TFiltroNota): TObjectList<TNota>;
var
  LQry: TFDQuery;
  LNumero: Integer;
begin
  Result := TObjectList<TNota>.Create;
  try
    LQry := FConexao.NovaQuery;
    try
      // os filtros opcionais usam "parâmetro nulo = sem filtro" para manter um SQL só
      LQry.SQL.Text := SQL_SELECT_NOTA +
        'WHERE N.DATA_EMISSAO >= :DATA_INI AND N.DATA_EMISSAO < :DATA_FIM ' +
        '  AND (CAST(:MODELO AS SMALLINT) IS NULL OR N.MODELO = :MODELO) ' +
        '  AND (CAST(:STATUS AS SMALLINT) IS NULL OR N.STATUS = :STATUS) ' +
        '  AND (CAST(:TEXTO AS VARCHAR(60)) IS NULL OR N.NUMERO = :NUMERO OR N.CHAVE = :TEXTO ' +
        '       OR UPPER(C.NOME) CONTAINING UPPER(:TEXTO)) ' +
        'ORDER BY N.DATA_EMISSAO DESC';

      LQry.ParamByName('DATA_INI').AsDateTime := StartOfTheDay(AFiltro.DataInicial);
      LQry.ParamByName('DATA_FIM').AsDateTime := StartOfTheDay(IncDay(AFiltro.DataFinal));
      ParamInteiroOuNulo(LQry.ParamByName('MODELO'), AFiltro.Modelo);

      LQry.ParamByName('STATUS').DataType := ftSmallint;
      if AFiltro.Status >= 0 then
        LQry.ParamByName('STATUS').AsInteger := AFiltro.Status
      else
        LQry.ParamByName('STATUS').Clear;

      ParamTextoOuNulo(LQry.ParamByName('TEXTO'), Trim(AFiltro.Texto));
      LQry.ParamByName('NUMERO').DataType := ftInteger;
      if TryStrToInt(Trim(AFiltro.Texto), LNumero) then
        LQry.ParamByName('NUMERO').AsInteger := LNumero
      else
        LQry.ParamByName('NUMERO').Clear;

      LQry.Open;
      while not LQry.Eof do
      begin
        Result.Add(LerCabecalho(LQry));
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

end.
