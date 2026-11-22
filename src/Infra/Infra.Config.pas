unit Infra.Config;

{
  Leitura do config.ini (fica ao lado do executável e NÃO é versionado).
  Tudo que é sensível - senha do banco, certificado, CSC, SMTP - vem daqui,
  nunca do código. Se o arquivo não existir, os valores padrão são usados e o
  ambiente fiscal fica sempre em homologação.
}

interface

uses
  Model.Tipos;

type
  TConfigBanco = record
    Servidor: string;
    Porta: Integer;
    Arquivo: string;
    Usuario: string;
    Senha: string;
    BibliotecaCliente: string;
  end;

  TConfigNFe = record
    Ambiente: TAmbienteFiscal;
    UF: string;
    Certificado: string;
    SenhaCertificado: string;
    PastaSchemas: string;
    PastaXml: string;
    IdCSC: string;
    CSC: string;
  end;

  // empresa que desenvolveu o software (grupo infRespTec da NF-e)
  TConfigResponsavelTecnico = record
    CNPJ: string;
    Contato: string;
    Email: string;
    Fone: string;
    IdCSRT: Integer;
    CSRT: string;
  end;

  TConfigMigracao = record
    CriarBanco: Boolean;
    Executar: Boolean;
    ExecutarSeeds: Boolean;
    Pasta: string;
  end;

  TConfigEmail = record
    Host: string;
    Porta: Integer;
    Usuario: string;
    Senha: string;
    TLS: Boolean;
    Remetente: string;
    NomeRemetente: string;
  end;

  // delphi-horse-api, de onde vêm os pedidos faturados no emissor
  TConfigApi = record
    Url: string;
    Usuario: string;
    Senha: string;
    TimeoutMs: Integer;
  end;

  TConfig = class
  private
    FArquivo: string;
    FBanco: TConfigBanco;
    FNFe: TConfigNFe;
    FEmail: TConfigEmail;
    FMigracao: TConfigMigracao;
    FResponsavelTecnico: TConfigResponsavelTecnico;
    FApi: TConfigApi;
    FPastaLog: string;
    class function CaminhoAbsoluto(const ACaminho: string): string; static;
  public
    constructor Create(const AArquivo: string);
    procedure Carregar;
    function ArquivoExiste: Boolean;
    property Arquivo: string read FArquivo;
    property Banco: TConfigBanco read FBanco;
    property NFe: TConfigNFe read FNFe;
    property Email: TConfigEmail read FEmail;
    property Migracao: TConfigMigracao read FMigracao;
    property ResponsavelTecnico: TConfigResponsavelTecnico read FResponsavelTecnico;
    property Api: TConfigApi read FApi;
    property PastaLog: string read FPastaLog;
  end;

/// Configuração da aplicação, carregada na primeira chamada.
function Config: TConfig;

/// Converte o texto do ini no ambiente. Qualquer coisa diferente de
/// "producao" resulta em homologação - produção nunca é o padrão.
function AmbienteDoTexto(const ATexto: string): TAmbienteFiscal;

implementation

uses
  System.SysUtils, System.IniFiles, System.IOUtils;

var
  GConfig: TConfig;

function Config: TConfig;
begin
  if GConfig = nil then
  begin
    GConfig := TConfig.Create(TPath.Combine(ExtractFilePath(ParamStr(0)), 'config.ini'));
    GConfig.Carregar;
  end;
  Result := GConfig;
end;

function AmbienteDoTexto(const ATexto: string): TAmbienteFiscal;
begin
  if SameText(Trim(ATexto), 'producao') then
    Result := TAmbienteFiscal.Producao
  else
    Result := TAmbienteFiscal.Homologacao;
end;

{ TConfig }

constructor TConfig.Create(const AArquivo: string);
begin
  inherited Create;
  FArquivo := AArquivo;
end;

function TConfig.ArquivoExiste: Boolean;
begin
  Result := FileExists(FArquivo);
end;

class function TConfig.CaminhoAbsoluto(const ACaminho: string): string;
begin
  if ACaminho.IsEmpty or TPath.IsPathRooted(ACaminho) then
    Result := ACaminho
  else
    Result := TPath.GetFullPath(TPath.Combine(ExtractFilePath(ParamStr(0)), ACaminho));
end;

procedure TConfig.Carregar;
var
  LIni: TMemIniFile;
begin
  LIni := TMemIniFile.Create(FArquivo, TEncoding.UTF8);
  try
    FBanco.Servidor := LIni.ReadString('Banco', 'Servidor', 'localhost');
    FBanco.Porta := LIni.ReadInteger('Banco', 'Porta', 3050);
    FBanco.Arquivo := LIni.ReadString('Banco', 'Arquivo', '');
    FBanco.Usuario := LIni.ReadString('Banco', 'Usuario', 'SYSDBA');
    FBanco.Senha := LIni.ReadString('Banco', 'Senha', '');
    FBanco.BibliotecaCliente := CaminhoAbsoluto(LIni.ReadString('Banco', 'BibliotecaCliente', ''));

    FNFe.Ambiente := AmbienteDoTexto(LIni.ReadString('NFe', 'Ambiente', 'homologacao'));
    FNFe.UF := UpperCase(LIni.ReadString('NFe', 'UF', 'SP'));
    FNFe.Certificado := CaminhoAbsoluto(LIni.ReadString('NFe', 'Certificado', ''));
    FNFe.SenhaCertificado := LIni.ReadString('NFe', 'SenhaCertificado', '');
    FNFe.PastaSchemas := CaminhoAbsoluto(LIni.ReadString('NFe', 'PastaSchemas', '.\Schemas'));
    FNFe.PastaXml := CaminhoAbsoluto(LIni.ReadString('NFe', 'PastaXml', '.\xml'));
    FNFe.IdCSC := LIni.ReadString('NFe', 'IdCSC', '');
    FNFe.CSC := LIni.ReadString('NFe', 'CSC', '');

    FEmail.Host := LIni.ReadString('Email', 'Host', '');
    FEmail.Porta := LIni.ReadInteger('Email', 'Porta', 587);
    FEmail.Usuario := LIni.ReadString('Email', 'Usuario', '');
    FEmail.Senha := LIni.ReadString('Email', 'Senha', '');
    FEmail.TLS := LIni.ReadBool('Email', 'TLS', True);
    FEmail.Remetente := LIni.ReadString('Email', 'Remetente', '');
    FEmail.NomeRemetente := LIni.ReadString('Email', 'NomeRemetente', '');

    FResponsavelTecnico.CNPJ := LIni.ReadString('ResponsavelTecnico', 'CNPJ', '');
    FResponsavelTecnico.Contato := LIni.ReadString('ResponsavelTecnico', 'Contato', '');
    FResponsavelTecnico.Email := LIni.ReadString('ResponsavelTecnico', 'Email', '');
    FResponsavelTecnico.Fone := LIni.ReadString('ResponsavelTecnico', 'Fone', '');
    FResponsavelTecnico.IdCSRT := LIni.ReadInteger('ResponsavelTecnico', 'IdCSRT', 0);
    FResponsavelTecnico.CSRT := LIni.ReadString('ResponsavelTecnico', 'CSRT', '');

    // CriarBanco desligado por padrão: caminho errado criaria um banco vazio em vez de dar erro
    FMigracao.CriarBanco := LIni.ReadBool('Migracao', 'CriarBanco', False);
    FMigracao.Executar := LIni.ReadBool('Migracao', 'Executar', True);
    FMigracao.ExecutarSeeds := LIni.ReadBool('Migracao', 'ExecutarSeeds', False);
    FMigracao.Pasta := CaminhoAbsoluto(LIni.ReadString('Migracao', 'Pasta', '.\database'));

    FApi.Url := LIni.ReadString('Api', 'Url', 'http://localhost:9000');
    FApi.Usuario := LIni.ReadString('Api', 'Usuario', '');
    FApi.Senha := LIni.ReadString('Api', 'Senha', '');
    FApi.TimeoutMs := LIni.ReadInteger('Api', 'TimeoutSegundos', 15) * 1000;

    FPastaLog := CaminhoAbsoluto(LIni.ReadString('Log', 'Pasta', '.\logs'));
  finally
    LIni.Free;
  end;
end;

initialization

finalization
  FreeAndNil(GConfig);

end.
