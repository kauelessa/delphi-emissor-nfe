unit Infra.Conexao;

interface

uses
  FireDAC.Comp.Client, FireDAC.Phys.FB;

type
  IConexao = interface
    ['{6B1E4C1A-3F0B-4C1E-9E59-2A7B9B4C8D10}']
    function Connection: TFDConnection;
    function NovaQuery: TFDQuery;
    procedure CriarBancoSeNaoExistir;
  end;

  TConexaoFirebird = class(TInterfacedObject, IConexao)
  private
    FDriver: TFDPhysFBDriverLink;
    FConnection: TFDConnection;
  public
    constructor Create;
    destructor Destroy; override;
    function Connection: TFDConnection;
    function NovaQuery: TFDQuery;
    procedure CriarBancoSeNaoExistir;
  end;

// uma conexão só para o app VCL (single thread)
function Conexao: IConexao;

implementation

uses
  System.SysUtils, FireDAC.Stan.Intf, FireDAC.Stan.Def, FireDAC.Stan.Async,
  FireDAC.Stan.Option, FireDAC.Phys, FireDAC.Phys.FBDef,
  FireDAC.DApt, FireDAC.UI.Intf, FireDAC.VCLUI.Wait, Infra.Config;

var
  GConexao: IConexao;

function Conexao: IConexao;
begin
  if GConexao = nil then
    GConexao := TConexaoFirebird.Create;
  Result := GConexao;
end;

{ TConexaoFirebird }

constructor TConexaoFirebird.Create;
var
  LBanco: TConfigBanco;
begin
  inherited;
  LBanco := Config.Banco;

  FDriver := TFDPhysFBDriverLink.Create(nil);
  if LBanco.BibliotecaCliente <> '' then
    FDriver.VendorLib := LBanco.BibliotecaCliente;

  FConnection := TFDConnection.Create(nil);
  FConnection.DriverName := 'FB';
  FConnection.LoginPrompt := False;
  FConnection.Params.Values['Server'] := LBanco.Servidor;
  FConnection.Params.Values['Port'] := LBanco.Porta.ToString;
  FConnection.Params.Values['Database'] := LBanco.Arquivo;
  FConnection.Params.Values['User_Name'] := LBanco.Usuario;
  FConnection.Params.Values['Password'] := LBanco.Senha;
  FConnection.Params.Values['Protocol'] := 'TCPIP';
  FConnection.Params.Values['CharacterSet'] := 'UTF8';
  // não conecta aqui: o FireDAC abre a conexão na primeira query
end;

destructor TConexaoFirebird.Destroy;
begin
  FConnection.Free;
  FDriver.Free;
  inherited;
end;

function TConexaoFirebird.Connection: TFDConnection;
begin
  Result := FConnection;
end;

function TConexaoFirebird.NovaQuery: TFDQuery;
begin
  Result := TFDQuery.Create(nil);
  Result.Connection := FConnection;
end;

procedure TConexaoFirebird.CriarBancoSeNaoExistir;
var
  LCon: TFDConnection;
begin
  // conexão separada: o OpenOrCreate não pode ficar valendo na conexão do sistema
  LCon := TFDConnection.Create(nil);
  try
    LCon.DriverName := 'FB';
    LCon.LoginPrompt := False;
    LCon.Params.Assign(FConnection.Params);
    LCon.Params.Values['OpenMode'] := 'OpenOrCreate';
    LCon.Params.Values['PageSize'] := '16384';
    LCon.Connected := True;
  finally
    LCon.Free;
  end;
end;

initialization

finalization
  GConexao := nil;

end.
