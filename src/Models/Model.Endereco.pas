unit Model.Endereco;

interface

type
  TEndereco = class
  private
    FLogradouro: string;
    FNumero: string;
    FComplemento: string;
    FBairro: string;
    FCodigoMunicipio: Integer;
    FMunicipio: string;
    FUF: string;
    FCEP: string;
  public
    procedure Assign(AOrigem: TEndereco);
    function Preenchido: Boolean;
    property Logradouro: string read FLogradouro write FLogradouro;
    property Numero: string read FNumero write FNumero;
    property Complemento: string read FComplemento write FComplemento;
    property Bairro: string read FBairro write FBairro;
    property CodigoMunicipio: Integer read FCodigoMunicipio write FCodigoMunicipio;
    property Municipio: string read FMunicipio write FMunicipio;
    property UF: string read FUF write FUF;
    property CEP: string read FCEP write FCEP;
  end;

implementation

procedure TEndereco.Assign(AOrigem: TEndereco);
begin
  FLogradouro := AOrigem.Logradouro;
  FNumero := AOrigem.Numero;
  FComplemento := AOrigem.Complemento;
  FBairro := AOrigem.Bairro;
  FCodigoMunicipio := AOrigem.CodigoMunicipio;
  FMunicipio := AOrigem.Municipio;
  FUF := AOrigem.UF;
  FCEP := AOrigem.CEP;
end;

function TEndereco.Preenchido: Boolean;
begin
  Result := (FLogradouro <> '') and (FCodigoMunicipio > 0) and (FUF <> '');
end;

end.
