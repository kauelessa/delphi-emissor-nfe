unit Model.Emitente;

interface

uses
  Model.Tipos, Model.Endereco;

type
  TEmitente = class
  private
    FId: Integer;
    FRazaoSocial: string;
    FNomeFantasia: string;
    FCNPJ: string;
    FIE: string;
    FRegime: TRegimeTributario;
    FEndereco: TEndereco;
    FTelefone: string;
    FEmail: string;
    FSerieNFe: Integer;
    FProximoNumeroNFe: Integer;
    FSerieNFCe: Integer;
    FProximoNumeroNFCe: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    function Serie(AModelo: TModeloNota): Integer;
    property Id: Integer read FId write FId;
    property RazaoSocial: string read FRazaoSocial write FRazaoSocial;
    property NomeFantasia: string read FNomeFantasia write FNomeFantasia;
    property CNPJ: string read FCNPJ write FCNPJ;
    property IE: string read FIE write FIE;
    property Regime: TRegimeTributario read FRegime write FRegime;
    property Endereco: TEndereco read FEndereco;
    property Telefone: string read FTelefone write FTelefone;
    property Email: string read FEmail write FEmail;
    property SerieNFe: Integer read FSerieNFe write FSerieNFe;
    property ProximoNumeroNFe: Integer read FProximoNumeroNFe write FProximoNumeroNFe;
    property SerieNFCe: Integer read FSerieNFCe write FSerieNFCe;
    property ProximoNumeroNFCe: Integer read FProximoNumeroNFCe write FProximoNumeroNFCe;
  end;

implementation

constructor TEmitente.Create;
begin
  inherited;
  FEndereco := TEndereco.Create;
  FRegime := TRegimeTributario.SimplesNacional;
  FSerieNFe := 1;
  FSerieNFCe := 1;
  FProximoNumeroNFe := 1;
  FProximoNumeroNFCe := 1;
end;

destructor TEmitente.Destroy;
begin
  FEndereco.Free;
  inherited;
end;

function TEmitente.Serie(AModelo: TModeloNota): Integer;
begin
  if AModelo = TModeloNota.NFCe then
    Result := FSerieNFCe
  else
    Result := FSerieNFe;
end;

end.
