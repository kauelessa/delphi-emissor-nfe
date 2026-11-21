unit Repository.Emitente;

interface

uses
  Model.Tipos, Model.Emitente, Infra.Conexao;

type
  IEmitenteRepository = interface
    ['{A3C1F0D2-8B7E-4E55-9C21-1D2E3F4A5B60}']
    function Obter: TEmitente;
    procedure Salvar(AEmitente: TEmitente);
    function ReservarNumero(AModelo: TModeloNota): Integer;
  end;

  TEmitenteRepository = class(TInterfacedObject, IEmitenteRepository)
  private
    FConexao: IConexao;
  public
    constructor Create(AConexao: IConexao);
    function Obter: TEmitente;
    procedure Salvar(AEmitente: TEmitente);
    function ReservarNumero(AModelo: TModeloNota): Integer;
  end;

implementation

uses
  System.SysUtils, Data.DB, FireDAC.Comp.Client, FireDAC.Stan.Param;

constructor TEmitenteRepository.Create(AConexao: IConexao);
begin
  inherited Create;
  FConexao := AConexao;
end;

function TEmitenteRepository.Obter: TEmitente;
var
  LQry: TFDQuery;
begin
  Result := nil;
  LQry := FConexao.NovaQuery;
  try
    // o sistema trabalha com um emitente só
    LQry.Open('SELECT FIRST 1 * FROM EMITENTE ORDER BY ID');
    if LQry.IsEmpty then
      Exit;

    Result := TEmitente.Create;
    Result.Id := LQry.FieldByName('ID').AsInteger;
    Result.RazaoSocial := LQry.FieldByName('RAZAO_SOCIAL').AsString;
    Result.NomeFantasia := LQry.FieldByName('NOME_FANTASIA').AsString;
    Result.CNPJ := LQry.FieldByName('CNPJ').AsString;
    Result.IE := LQry.FieldByName('IE').AsString;
    Result.Regime := TRegimeTributario.DeCodigo(LQry.FieldByName('CRT').AsInteger);
    Result.Endereco.Logradouro := LQry.FieldByName('LOGRADOURO').AsString;
    Result.Endereco.Numero := LQry.FieldByName('NUMERO').AsString;
    Result.Endereco.Complemento := LQry.FieldByName('COMPLEMENTO').AsString;
    Result.Endereco.Bairro := LQry.FieldByName('BAIRRO').AsString;
    Result.Endereco.CodigoMunicipio := LQry.FieldByName('CODIGO_MUNICIPIO').AsInteger;
    Result.Endereco.Municipio := LQry.FieldByName('MUNICIPIO').AsString;
    Result.Endereco.UF := Trim(LQry.FieldByName('UF').AsString);
    Result.Endereco.CEP := LQry.FieldByName('CEP').AsString;
    Result.Telefone := LQry.FieldByName('TELEFONE').AsString;
    Result.Email := LQry.FieldByName('EMAIL').AsString;
    Result.SerieNFe := LQry.FieldByName('SERIE_NFE').AsInteger;
    Result.ProximoNumeroNFe := LQry.FieldByName('PROXIMO_NUMERO_NFE').AsInteger;
    Result.SerieNFCe := LQry.FieldByName('SERIE_NFCE').AsInteger;
    Result.ProximoNumeroNFCe := LQry.FieldByName('PROXIMO_NUMERO_NFCE').AsInteger;
  finally
    LQry.Free;
  end;
end;

procedure TEmitenteRepository.Salvar(AEmitente: TEmitente);
var
  LQry: TFDQuery;
begin
  LQry := FConexao.NovaQuery;
  try
    if AEmitente.Id = 0 then
      LQry.SQL.Text :=
        'INSERT INTO EMITENTE (RAZAO_SOCIAL, NOME_FANTASIA, CNPJ, IE, CRT, LOGRADOURO, NUMERO, ' +
        '  COMPLEMENTO, BAIRRO, CODIGO_MUNICIPIO, MUNICIPIO, UF, CEP, TELEFONE, EMAIL, ' +
        '  SERIE_NFE, PROXIMO_NUMERO_NFE, SERIE_NFCE, PROXIMO_NUMERO_NFCE) ' +
        'VALUES (:RAZAO_SOCIAL, :NOME_FANTASIA, :CNPJ, :IE, :CRT, :LOGRADOURO, :NUMERO, ' +
        '  :COMPLEMENTO, :BAIRRO, :CODIGO_MUNICIPIO, :MUNICIPIO, :UF, :CEP, :TELEFONE, :EMAIL, ' +
        '  :SERIE_NFE, :PROXIMO_NUMERO_NFE, :SERIE_NFCE, :PROXIMO_NUMERO_NFCE) ' +
        'RETURNING ID'
    else
      LQry.SQL.Text :=
        'UPDATE EMITENTE SET RAZAO_SOCIAL = :RAZAO_SOCIAL, NOME_FANTASIA = :NOME_FANTASIA, ' +
        '  CNPJ = :CNPJ, IE = :IE, CRT = :CRT, LOGRADOURO = :LOGRADOURO, NUMERO = :NUMERO, ' +
        '  COMPLEMENTO = :COMPLEMENTO, BAIRRO = :BAIRRO, CODIGO_MUNICIPIO = :CODIGO_MUNICIPIO, ' +
        '  MUNICIPIO = :MUNICIPIO, UF = :UF, CEP = :CEP, TELEFONE = :TELEFONE, EMAIL = :EMAIL, ' +
        '  SERIE_NFE = :SERIE_NFE, PROXIMO_NUMERO_NFE = :PROXIMO_NUMERO_NFE, ' +
        '  SERIE_NFCE = :SERIE_NFCE, PROXIMO_NUMERO_NFCE = :PROXIMO_NUMERO_NFCE ' +
        'WHERE ID = :ID RETURNING ID';

    LQry.ParamByName('RAZAO_SOCIAL').AsString := AEmitente.RazaoSocial;
    LQry.ParamByName('NOME_FANTASIA').AsString := AEmitente.NomeFantasia;
    LQry.ParamByName('CNPJ').AsString := AEmitente.CNPJ;
    LQry.ParamByName('IE').AsString := AEmitente.IE;
    LQry.ParamByName('CRT').AsInteger := AEmitente.Regime.Codigo;
    LQry.ParamByName('LOGRADOURO').AsString := AEmitente.Endereco.Logradouro;
    LQry.ParamByName('NUMERO').AsString := AEmitente.Endereco.Numero;
    LQry.ParamByName('COMPLEMENTO').AsString := AEmitente.Endereco.Complemento;
    LQry.ParamByName('BAIRRO').AsString := AEmitente.Endereco.Bairro;
    LQry.ParamByName('CODIGO_MUNICIPIO').AsInteger := AEmitente.Endereco.CodigoMunicipio;
    LQry.ParamByName('MUNICIPIO').AsString := AEmitente.Endereco.Municipio;
    LQry.ParamByName('UF').AsString := AEmitente.Endereco.UF;
    LQry.ParamByName('CEP').AsString := AEmitente.Endereco.CEP;
    LQry.ParamByName('TELEFONE').AsString := AEmitente.Telefone;
    LQry.ParamByName('EMAIL').AsString := AEmitente.Email;
    LQry.ParamByName('SERIE_NFE').AsInteger := AEmitente.SerieNFe;
    LQry.ParamByName('PROXIMO_NUMERO_NFE').AsInteger := AEmitente.ProximoNumeroNFe;
    LQry.ParamByName('SERIE_NFCE').AsInteger := AEmitente.SerieNFCe;
    LQry.ParamByName('PROXIMO_NUMERO_NFCE').AsInteger := AEmitente.ProximoNumeroNFCe;
    if AEmitente.Id > 0 then
      LQry.ParamByName('ID').AsInteger := AEmitente.Id;

    LQry.Open;
    AEmitente.Id := LQry.FieldByName('ID').AsInteger;
  finally
    LQry.Free;
  end;
end;

function TEmitenteRepository.ReservarNumero(AModelo: TModeloNota): Integer;
var
  LQry: TFDQuery;
begin
  // o UPDATE trava a linha do emitente até o commit, então duas estações
  // nunca pegam o mesmo número
  LQry := FConexao.NovaQuery;
  try
    if AModelo = TModeloNota.NFCe then
      LQry.SQL.Text := 'UPDATE EMITENTE SET PROXIMO_NUMERO_NFCE = PROXIMO_NUMERO_NFCE + 1 ' +
        'RETURNING PROXIMO_NUMERO_NFCE - 1 AS NUMERO'
    else
      LQry.SQL.Text := 'UPDATE EMITENTE SET PROXIMO_NUMERO_NFE = PROXIMO_NUMERO_NFE + 1 ' +
        'RETURNING PROXIMO_NUMERO_NFE - 1 AS NUMERO';
    LQry.Open;
    if LQry.IsEmpty then
      raise EValidacao.Create('Emitente não cadastrado');
    Result := LQry.FieldByName('NUMERO').AsInteger;
  finally
    LQry.Free;
  end;
end;

end.
