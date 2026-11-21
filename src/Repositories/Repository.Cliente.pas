unit Repository.Cliente;

interface

uses
  System.Generics.Collections, Model.Cliente, Infra.Conexao;

type
  IClienteRepository = interface
    ['{B4D2A1E3-9C8F-4F66-8D32-2E3F4A5B6C71}']
    function Listar(const AFiltro: string): TObjectList<TCliente>;
    function Obter(AId: Integer): TCliente;
    procedure Salvar(ACliente: TCliente);
    procedure Inativar(AId: Integer);
  end;

  TClienteRepository = class(TInterfacedObject, IClienteRepository)
  private
    FConexao: IConexao;
  public
    constructor Create(AConexao: IConexao);
    function Listar(const AFiltro: string): TObjectList<TCliente>;
    function Obter(AId: Integer): TCliente;
    procedure Salvar(ACliente: TCliente);
    procedure Inativar(AId: Integer);
  end;

implementation

uses
  System.SysUtils, Data.DB, FireDAC.Comp.Client, FireDAC.Stan.Param, Model.Tipos, Infra.Documento;

function LerCliente(AQry: TDataSet): TCliente;
begin
  Result := TCliente.Create;
  Result.Id := AQry.FieldByName('ID').AsInteger;
  Result.Nome := AQry.FieldByName('NOME').AsString;
  Result.CpfCnpj := AQry.FieldByName('CPF_CNPJ').AsString;
  Result.IE := AQry.FieldByName('IE').AsString;
  Result.IndicadorIE := TIndicadorIE.DeCodigo(AQry.FieldByName('INDICADOR_IE').AsInteger);
  Result.Email := AQry.FieldByName('EMAIL').AsString;
  Result.Telefone := AQry.FieldByName('TELEFONE').AsString;
  Result.Endereco.Logradouro := AQry.FieldByName('LOGRADOURO').AsString;
  Result.Endereco.Numero := AQry.FieldByName('NUMERO').AsString;
  Result.Endereco.Complemento := AQry.FieldByName('COMPLEMENTO').AsString;
  Result.Endereco.Bairro := AQry.FieldByName('BAIRRO').AsString;
  Result.Endereco.CodigoMunicipio := AQry.FieldByName('CODIGO_MUNICIPIO').AsInteger;
  Result.Endereco.Municipio := AQry.FieldByName('MUNICIPIO').AsString;
  Result.Endereco.UF := Trim(AQry.FieldByName('UF').AsString);
  Result.Endereco.CEP := AQry.FieldByName('CEP').AsString;
  Result.Ativo := AQry.FieldByName('ATIVO').AsBoolean;
end;

constructor TClienteRepository.Create(AConexao: IConexao);
begin
  inherited Create;
  FConexao := AConexao;
end;

function TClienteRepository.Listar(const AFiltro: string): TObjectList<TCliente>;
var
  LQry: TFDQuery;
  LDoc: string;
begin
  Result := TObjectList<TCliente>.Create;
  try
    LQry := FConexao.NovaQuery;
    try
      LDoc := SoNumeros(AFiltro);
      if Trim(AFiltro) = '' then
        LQry.SQL.Text := 'SELECT * FROM CLIENTE WHERE ATIVO = TRUE ORDER BY NOME'
      else if LDoc <> '' then
      begin
        LQry.SQL.Text := 'SELECT * FROM CLIENTE WHERE ATIVO = TRUE ' +
          'AND (UPPER(NOME) CONTAINING UPPER(:FILTRO) OR CPF_CNPJ STARTING WITH :DOC) ORDER BY NOME';
        LQry.ParamByName('DOC').AsString := LDoc;
      end
      else
        LQry.SQL.Text := 'SELECT * FROM CLIENTE WHERE ATIVO = TRUE ' +
          'AND UPPER(NOME) CONTAINING UPPER(:FILTRO) ORDER BY NOME';

      if Trim(AFiltro) <> '' then
        LQry.ParamByName('FILTRO').AsString := Trim(AFiltro);
      LQry.Open;

      while not LQry.Eof do
      begin
        Result.Add(LerCliente(LQry));
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

function TClienteRepository.Obter(AId: Integer): TCliente;
var
  LQry: TFDQuery;
begin
  LQry := FConexao.NovaQuery;
  try
    LQry.Open('SELECT * FROM CLIENTE WHERE ID = :ID', [AId]);
    if LQry.IsEmpty then
      Result := nil
    else
      Result := LerCliente(LQry);
  finally
    LQry.Free;
  end;
end;

procedure TClienteRepository.Salvar(ACliente: TCliente);
var
  LQry: TFDQuery;
begin
  LQry := FConexao.NovaQuery;
  try
    if ACliente.Id = 0 then
      LQry.SQL.Text :=
        'INSERT INTO CLIENTE (NOME, CPF_CNPJ, IE, INDICADOR_IE, EMAIL, TELEFONE, LOGRADOURO, ' +
        '  NUMERO, COMPLEMENTO, BAIRRO, CODIGO_MUNICIPIO, MUNICIPIO, UF, CEP, ATIVO) ' +
        'VALUES (:NOME, :CPF_CNPJ, :IE, :INDICADOR_IE, :EMAIL, :TELEFONE, :LOGRADOURO, ' +
        '  :NUMERO, :COMPLEMENTO, :BAIRRO, :CODIGO_MUNICIPIO, :MUNICIPIO, :UF, :CEP, :ATIVO) ' +
        'RETURNING ID'
    else
      LQry.SQL.Text :=
        'UPDATE CLIENTE SET NOME = :NOME, CPF_CNPJ = :CPF_CNPJ, IE = :IE, ' +
        '  INDICADOR_IE = :INDICADOR_IE, EMAIL = :EMAIL, TELEFONE = :TELEFONE, ' +
        '  LOGRADOURO = :LOGRADOURO, NUMERO = :NUMERO, COMPLEMENTO = :COMPLEMENTO, ' +
        '  BAIRRO = :BAIRRO, CODIGO_MUNICIPIO = :CODIGO_MUNICIPIO, MUNICIPIO = :MUNICIPIO, ' +
        '  UF = :UF, CEP = :CEP, ATIVO = :ATIVO ' +
        'WHERE ID = :ID RETURNING ID';

    LQry.ParamByName('NOME').AsString := ACliente.Nome;
    LQry.ParamByName('CPF_CNPJ').AsString := ACliente.CpfCnpj;
    LQry.ParamByName('IE').AsString := ACliente.IE;
    LQry.ParamByName('INDICADOR_IE').AsInteger := ACliente.IndicadorIE.Codigo;
    LQry.ParamByName('EMAIL').AsString := ACliente.Email;
    LQry.ParamByName('TELEFONE').AsString := ACliente.Telefone;
    LQry.ParamByName('LOGRADOURO').AsString := ACliente.Endereco.Logradouro;
    LQry.ParamByName('NUMERO').AsString := ACliente.Endereco.Numero;
    LQry.ParamByName('COMPLEMENTO').AsString := ACliente.Endereco.Complemento;
    LQry.ParamByName('BAIRRO').AsString := ACliente.Endereco.Bairro;
    LQry.ParamByName('CODIGO_MUNICIPIO').AsInteger := ACliente.Endereco.CodigoMunicipio;
    LQry.ParamByName('MUNICIPIO').AsString := ACliente.Endereco.Municipio;
    LQry.ParamByName('UF').AsString := ACliente.Endereco.UF;
    LQry.ParamByName('CEP').AsString := ACliente.Endereco.CEP;
    LQry.ParamByName('ATIVO').AsBoolean := ACliente.Ativo;
    if ACliente.Id > 0 then
      LQry.ParamByName('ID').AsInteger := ACliente.Id;

    LQry.Open;
    ACliente.Id := LQry.FieldByName('ID').AsInteger;
  finally
    LQry.Free;
  end;
end;

procedure TClienteRepository.Inativar(AId: Integer);
begin
  // não apaga: o cliente pode estar em notas já emitidas
  FConexao.Connection.ExecSQL('UPDATE CLIENTE SET ATIVO = FALSE WHERE ID = :ID', [AId]);
end;

end.
