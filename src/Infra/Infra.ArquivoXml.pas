unit Infra.ArquivoXml;

interface

type
  IArquivoXml = interface
    ['{0C9A7E21-5D44-4F8B-A1E3-9B6C2D7F4E55}']
    /// Grava o XML em <PastaXml>\<CNPJ>\<AAAAMM>\<Nome>.xml e devolve o caminho.
    function Salvar(const ACnpj, ANome, AConteudo: string; AData: TDateTime): string;
    function Ler(const ACaminho: string): string;
  end;

  TArquivoXmlDisco = class(TInterfacedObject, IArquivoXml)
  private
    FPastaBase: string;
  public
    constructor Create(const APastaBase: string);
    function Salvar(const ACnpj, ANome, AConteudo: string; AData: TDateTime): string;
    function Ler(const ACaminho: string): string;
  end;

implementation

uses
  System.SysUtils, System.IOUtils;

constructor TArquivoXmlDisco.Create(const APastaBase: string);
begin
  inherited Create;
  FPastaBase := APastaBase;
end;

function TArquivoXmlDisco.Salvar(const ACnpj, ANome, AConteudo: string; AData: TDateTime): string;
var
  LPasta: string;
  LEncoding: TEncoding;
begin
  LPasta := TPath.Combine(TPath.Combine(FPastaBase, ACnpj), FormatDateTime('yyyymm', AData));
  ForceDirectories(LPasta);
  Result := TPath.Combine(LPasta, ANome + '.xml');

  // XML da SEFAZ é UTF-8 sem BOM
  LEncoding := TUTF8Encoding.Create(False);
  try
    TFile.WriteAllText(Result, AConteudo, LEncoding);
  finally
    LEncoding.Free;
  end;
end;

function TArquivoXmlDisco.Ler(const ACaminho: string): string;
begin
  if not FileExists(ACaminho) then
    raise EFileNotFoundException.CreateFmt('XML não encontrado: %s', [ACaminho]);
  Result := TFile.ReadAllText(ACaminho, TEncoding.UTF8);
end;

end.
