unit Infra.ApiPedidos;

{
  Leitura de pedidos e clientes da delphi-horse-api, para faturar os pedidos no emissor.

  É a única unit do emissor que fala HTTP. O transporte (IHttpTransporte) é separado
  da lógica da API para os testes trocarem a rede por respostas prontas.

  Autenticação: login na primeira chamada (POST /auth/login) e o token JWT fica em
  memória. A API não renova tokens; quando um expira (401), faz um novo login e repete
  a chamada UMA vez. Um segundo 401 vira erro.
}

interface

uses
  System.SysUtils, Model.PedidoApi;

type
  EApiPedidos = class(Exception);

  THttpResposta = record
    Status: Integer;
    Corpo: string;
  end;

  IHttpTransporte = interface
    ['{8E2F4B6A-1C3D-4E5F-9A7B-2D4C6E8F0A13}']
    function Executar(const AMetodo, AUrl, ACorpo, AToken: string): THttpResposta;
  end;

  TNetHttpTransporte = class(TInterfacedObject, IHttpTransporte)
  private
    FTimeoutMs: Integer;
  public
    constructor Create(ATimeoutMs: Integer);
    function Executar(const AMetodo, AUrl, ACorpo, AToken: string): THttpResposta;
  end;

  IPedidoApi = interface
    ['{5B7D9F1A-3C2E-4A6B-8D0F-1E3A5C7B9D24}']
    function Listar(APagina, ALimite: Integer): TPaginaPedidosApi;
    function Obter(AId: Integer): TPedidoApi;
    function ObterCliente(AId: Integer): TClienteApi;
  end;

  TPedidoApiHttp = class(TInterfacedObject, IPedidoApi)
  private
    FTransporte: IHttpTransporte;
    FUrl: string;
    FUsuario: string;
    FSenha: string;
    FToken: string;
    function Chamar(const AMetodo, AUrl, ACorpo, AToken: string): THttpResposta;
    procedure Logar;
    function Get(const ARota: string): string;
  public
    constructor Create(ATransporte: IHttpTransporte; const AUrl, AUsuario, ASenha: string);
    function Listar(APagina, ALimite: Integer): TPaginaPedidosApi;
    function Obter(AId: Integer): TPedidoApi;
    function ObterCliente(AId: Integer): TClienteApi;
  end;

implementation

uses
  System.Classes, System.JSON, System.DateUtils, System.Net.HttpClient,
  System.Net.URLClient, Infra.Log;

{ leitura de JSON }

function ParseObjeto(const ATexto: string): TJSONObject;
var
  LValor: TJSONValue;
begin
  LValor := TJSONObject.ParseJSONValue(ATexto);
  if not (LValor is TJSONObject) then
  begin
    LValor.Free;
    raise EApiPedidos.Create('Resposta inválida da API.');
  end;
  Result := TJSONObject(LValor);
end;

function Texto(AJson: TJSONObject; const ACampo: string): string;
begin
  if not AJson.TryGetValue<string>(ACampo, Result) then
    Result := '';
end;

function Inteiro(AJson: TJSONObject; const ACampo: string): Integer;
var
  LValor: TJSONValue;
begin
  LValor := AJson.GetValue(ACampo);
  if LValor is TJSONNumber then
    Result := TJSONNumber(LValor).AsInt
  else
    Result := 0;
end;

function Valor(AJson: TJSONObject; const ACampo: string): Currency;
var
  LValor: TJSONValue;
begin
  // TJSONNumber lê com ponto decimal, seja qual for a configuração regional do Windows
  LValor := AJson.GetValue(ACampo);
  if LValor is TJSONNumber then
    Result := TJSONNumber(LValor).AsDouble
  else
    Result := 0;
end;

function LerPedido(AJson: TJSONObject): TPedidoApi;
var
  LCliente: TJSONObject;
  LItens: TJSONArray;
  LElemento: TJSONValue;
  LItem: TItemPedidoApi;
  LData: string;
begin
  Result := TPedidoApi.Create;
  try
    Result.Id := Inteiro(AJson, 'id');
    if AJson.TryGetValue<TJSONObject>('cliente', LCliente) then
    begin
      Result.ClienteId := Inteiro(LCliente, 'id');
      Result.ClienteNome := Texto(LCliente, 'nome');
    end;
    LData := Texto(AJson, 'data');
    if LData <> '' then
      Result.Data := ISO8601ToDate(LData, False);
    if SameText(Texto(AJson, 'status'), 'CANCELADO') then
      Result.Status := TStatusPedidoApi.Cancelado
    else
      Result.Status := TStatusPedidoApi.Aberto;
    Result.ValorTotal := Valor(AJson, 'valorTotal');

    if AJson.TryGetValue<TJSONArray>('itens', LItens) then
      for LElemento in LItens do
      begin
        LItem := TItemPedidoApi.Create;
        Result.Itens.Add(LItem);
        LItem.ProdutoId := Inteiro(TJSONObject(LElemento), 'produtoId');
        LItem.Descricao := Texto(TJSONObject(LElemento), 'descricao');
        LItem.Quantidade := Inteiro(TJSONObject(LElemento), 'quantidade');
        LItem.PrecoUnitario := Valor(TJSONObject(LElemento), 'precoUnitario');
        LItem.ValorTotal := Valor(TJSONObject(LElemento), 'valorTotal');
      end;
  except
    Result.Free;
    raise;
  end;
end;

{ TNetHttpTransporte }

constructor TNetHttpTransporte.Create(ATimeoutMs: Integer);
begin
  inherited Create;
  FTimeoutMs := ATimeoutMs;
end;

function TNetHttpTransporte.Executar(const AMetodo, AUrl, ACorpo, AToken: string): THttpResposta;
var
  LCliente: THTTPClient;
  LCorpo: TStringStream;
  LResposta: IHTTPResponse;
  LCabecalhos: TNetHeaders;
begin
  LCliente := THTTPClient.Create;
  LCorpo := nil;
  try
    LCliente.ConnectionTimeout := FTimeoutMs;
    LCliente.ResponseTimeout := FTimeoutMs;
    LCliente.Accept := 'application/json';
    LCliente.ContentType := 'application/json';
    if AToken <> '' then
      LCabecalhos := [TNetHeader.Create('Authorization', 'Bearer ' + AToken)];

    if ACorpo <> '' then
      LCorpo := TStringStream.Create(ACorpo, TEncoding.UTF8);
    // só GET e POST: o emissor apenas lê pedidos (o POST é o login)
    if AMetodo = 'POST' then
      LResposta := LCliente.Post(AUrl, LCorpo, nil, LCabecalhos)
    else
      LResposta := LCliente.Get(AUrl, nil, LCabecalhos);
    Result.Status := LResposta.StatusCode;
    Result.Corpo := LResposta.ContentAsString(TEncoding.UTF8);
  finally
    LCorpo.Free;
    LCliente.Free;
  end;
end;

{ TPedidoApiHttp }

constructor TPedidoApiHttp.Create(ATransporte: IHttpTransporte; const AUrl, AUsuario, ASenha: string);
begin
  inherited Create;
  FTransporte := ATransporte;
  FUrl := AUrl;
  while FUrl.EndsWith('/') do
    FUrl := FUrl.Substring(0, FUrl.Length - 1);
  FUsuario := AUsuario;
  FSenha := ASenha;
end;

function TPedidoApiHttp.Chamar(const AMetodo, AUrl, ACorpo, AToken: string): THttpResposta;
var
  LJson: TJSONObject;
  LErro: string;
begin
  try
    Result := FTransporte.Executar(AMetodo, AUrl, ACorpo, AToken);
  except
    on E: ENetException do
    begin
      Log.Erro(Format('API de pedidos: %s %s falhou (%s)', [AMetodo, AUrl, E.Message]));
      raise EApiPedidos.CreateFmt('Não foi possível conectar à API em %s.', [FUrl]);
    end;
  end;

  if Result.Status >= 500 then
    Log.Erro(Format('API de pedidos: %s %s respondeu %d', [AMetodo, AUrl, Result.Status]));

  if (Result.Status >= 400) and (Result.Status <> 401) then
  begin
    LErro := '';
    LJson := nil;
    try
      if Result.Corpo <> '' then
        LJson := TJSONObject.ParseJSONValue(Result.Corpo) as TJSONObject;
    except
      LJson := nil; // corpo que não é JSON: fica a mensagem com o status
    end;
    try
      if LJson <> nil then
        LErro := Texto(LJson, 'erro');
    finally
      LJson.Free;
    end;
    if LErro = '' then
      LErro := Format('A API respondeu %d.', [Result.Status]);
    raise EApiPedidos.Create(LErro);
  end;
end;

procedure TPedidoApiHttp.Logar;
var
  LCorpo, LJson: TJSONObject;
  LResposta: THttpResposta;
begin
  LCorpo := TJSONObject.Create;
  try
    LCorpo.AddPair('login', FUsuario).AddPair('senha', FSenha);
    LResposta := Chamar('POST', FUrl + '/auth/login', LCorpo.ToJSON, '');
  finally
    LCorpo.Free;
  end;
  if LResposta.Status = 401 then
    raise EApiPedidos.Create('Usuário ou senha da API inválidos. Confira a seção [Api] do config.ini.');

  LJson := ParseObjeto(LResposta.Corpo);
  try
    FToken := Texto(LJson, 'token');
  finally
    LJson.Free;
  end;
end;

function TPedidoApiHttp.Get(const ARota: string): string;
var
  LResposta: THttpResposta;
begin
  if FToken = '' then
    Logar;
  LResposta := Chamar('GET', FUrl + ARota, '', FToken);
  if LResposta.Status = 401 then
  begin
    // token expirado: um novo login e uma nova tentativa
    Logar;
    LResposta := Chamar('GET', FUrl + ARota, '', FToken);
    if LResposta.Status = 401 then
      raise EApiPedidos.Create('A API recusou o acesso mesmo depois de um novo login.');
  end;
  Result := LResposta.Corpo;
end;

function TPedidoApiHttp.Listar(APagina, ALimite: Integer): TPaginaPedidosApi;
var
  LJson: TJSONObject;
  LDados: TJSONArray;
  LElemento: TJSONValue;
begin
  LJson := ParseObjeto(Get(Format('/pedidos?pagina=%d&limite=%d', [APagina, ALimite])));
  try
    Result := TPaginaPedidosApi.Create;
    try
      Result.Pagina := Inteiro(LJson, 'pagina');
      Result.Total := Inteiro(LJson, 'total');
      if LJson.TryGetValue<TJSONArray>('dados', LDados) then
        for LElemento in LDados do
          Result.Pedidos.Add(LerPedido(TJSONObject(LElemento)));
    except
      Result.Free;
      raise;
    end;
  finally
    LJson.Free;
  end;
end;

function TPedidoApiHttp.Obter(AId: Integer): TPedidoApi;
var
  LJson: TJSONObject;
begin
  LJson := ParseObjeto(Get('/pedidos/' + AId.ToString));
  try
    Result := LerPedido(LJson);
  finally
    LJson.Free;
  end;
end;

function TPedidoApiHttp.ObterCliente(AId: Integer): TClienteApi;
var
  LJson: TJSONObject;
begin
  LJson := ParseObjeto(Get('/clientes/' + AId.ToString));
  try
    Result := TClienteApi.Create;
    Result.Id := Inteiro(LJson, 'id');
    Result.Nome := Texto(LJson, 'nome');
    Result.Documento := Texto(LJson, 'documento');
    Result.Email := Texto(LJson, 'email');
    Result.Telefone := Texto(LJson, 'telefone');
  finally
    LJson.Free;
  end;
end;

end.
