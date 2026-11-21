unit Repository.FormaPagamento;

interface

uses
  System.Generics.Collections, Model.FormaPagamento, Infra.Conexao;

type
  IFormaPagamentoRepository = interface
    ['{D6F4C3A5-BEA1-4188-AF54-4A5B6C7D8E93}']
    function Listar(AApenasAtivas: Boolean = True): TObjectList<TFormaPagamento>;
    function Obter(AId: Integer): TFormaPagamento;
    procedure Salvar(AForma: TFormaPagamento);
  end;

  TFormaPagamentoRepository = class(TInterfacedObject, IFormaPagamentoRepository)
  private
    FConexao: IConexao;
  public
    constructor Create(AConexao: IConexao);
    function Listar(AApenasAtivas: Boolean = True): TObjectList<TFormaPagamento>;
    function Obter(AId: Integer): TFormaPagamento;
    procedure Salvar(AForma: TFormaPagamento);
  end;

implementation

uses
  System.SysUtils, Data.DB, FireDAC.Comp.Client, FireDAC.Stan.Param;

function LerForma(AQry: TDataSet): TFormaPagamento;
begin
  Result := TFormaPagamento.Create;
  Result.Id := AQry.FieldByName('ID').AsInteger;
  Result.Descricao := AQry.FieldByName('DESCRICAO').AsString;
  Result.CodigoSefaz := AQry.FieldByName('CODIGO_SEFAZ').AsString;
  Result.Ativo := AQry.FieldByName('ATIVO').AsBoolean;
end;

constructor TFormaPagamentoRepository.Create(AConexao: IConexao);
begin
  inherited Create;
  FConexao := AConexao;
end;

function TFormaPagamentoRepository.Listar(AApenasAtivas: Boolean): TObjectList<TFormaPagamento>;
var
  LQry: TFDQuery;
begin
  Result := TObjectList<TFormaPagamento>.Create;
  try
    LQry := FConexao.NovaQuery;
    try
      if AApenasAtivas then
        LQry.Open('SELECT * FROM FORMA_PAGAMENTO WHERE ATIVO = TRUE ORDER BY DESCRICAO')
      else
        LQry.Open('SELECT * FROM FORMA_PAGAMENTO ORDER BY DESCRICAO');
      while not LQry.Eof do
      begin
        Result.Add(LerForma(LQry));
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

function TFormaPagamentoRepository.Obter(AId: Integer): TFormaPagamento;
var
  LQry: TFDQuery;
begin
  LQry := FConexao.NovaQuery;
  try
    LQry.Open('SELECT * FROM FORMA_PAGAMENTO WHERE ID = :ID', [AId]);
    if LQry.IsEmpty then
      Result := nil
    else
      Result := LerForma(LQry);
  finally
    LQry.Free;
  end;
end;

procedure TFormaPagamentoRepository.Salvar(AForma: TFormaPagamento);
var
  LQry: TFDQuery;
begin
  LQry := FConexao.NovaQuery;
  try
    if AForma.Id = 0 then
      LQry.SQL.Text := 'INSERT INTO FORMA_PAGAMENTO (DESCRICAO, CODIGO_SEFAZ, ATIVO) ' +
        'VALUES (:DESCRICAO, :CODIGO_SEFAZ, :ATIVO) RETURNING ID'
    else
    begin
      LQry.SQL.Text := 'UPDATE FORMA_PAGAMENTO SET DESCRICAO = :DESCRICAO, ' +
        'CODIGO_SEFAZ = :CODIGO_SEFAZ, ATIVO = :ATIVO WHERE ID = :ID RETURNING ID';
      LQry.ParamByName('ID').AsInteger := AForma.Id;
    end;
    LQry.ParamByName('DESCRICAO').AsString := AForma.Descricao;
    LQry.ParamByName('CODIGO_SEFAZ').AsString := AForma.CodigoSefaz;
    LQry.ParamByName('ATIVO').AsBoolean := AForma.Ativo;
    LQry.Open;
    AForma.Id := LQry.FieldByName('ID').AsInteger;
  finally
    LQry.Free;
  end;
end;

end.
