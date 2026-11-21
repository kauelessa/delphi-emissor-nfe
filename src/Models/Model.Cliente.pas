unit Model.Cliente;

interface

uses
  Model.Tipos, Model.Endereco;

type
  TCliente = class
  private
    FId: Integer;
    FNome: string;
    FCpfCnpj: string;
    FIE: string;
    FIndicadorIE: TIndicadorIE;
    FEmail: string;
    FTelefone: string;
    FEndereco: TEndereco;
    FAtivo: Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    function PessoaJuridica: Boolean;
    property Id: Integer read FId write FId;
    property Nome: string read FNome write FNome;
    property CpfCnpj: string read FCpfCnpj write FCpfCnpj;
    property IE: string read FIE write FIE;
    property IndicadorIE: TIndicadorIE read FIndicadorIE write FIndicadorIE;
    property Email: string read FEmail write FEmail;
    property Telefone: string read FTelefone write FTelefone;
    property Endereco: TEndereco read FEndereco;
    property Ativo: Boolean read FAtivo write FAtivo;
  end;

implementation

constructor TCliente.Create;
begin
  inherited;
  FEndereco := TEndereco.Create;
  FIndicadorIE := TIndicadorIE.NaoContribuinte;
  FAtivo := True;
end;

destructor TCliente.Destroy;
begin
  FEndereco.Free;
  inherited;
end;

function TCliente.PessoaJuridica: Boolean;
begin
  Result := Length(FCpfCnpj) = 14;
end;

end.
