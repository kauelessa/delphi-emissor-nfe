unit Service.Emitente;

interface

uses
  Model.Emitente, Repository.Emitente;

type
  IEmitenteService = interface
    ['{3C4D5E6F-7A8B-4C9D-0E1F-2A3B4C5D6E7F}']
    function Obter: TEmitente;
    procedure Salvar(AEmitente: TEmitente);
  end;

  TEmitenteService = class(TInterfacedObject, IEmitenteService)
  private
    FRepo: IEmitenteRepository;
  public
    constructor Create(ARepo: IEmitenteRepository);
    function Obter: TEmitente;
    procedure Salvar(AEmitente: TEmitente);
  end;

implementation

uses
  System.SysUtils, Model.Tipos, Infra.Documento;

constructor TEmitenteService.Create(ARepo: IEmitenteRepository);
begin
  inherited Create;
  FRepo := ARepo;
end;

function TEmitenteService.Obter: TEmitente;
begin
  Result := FRepo.Obter;
  if Result = nil then
    Result := TEmitente.Create;
end;

procedure TEmitenteService.Salvar(AEmitente: TEmitente);
begin
  AEmitente.CNPJ := SoNumeros(AEmitente.CNPJ);
  AEmitente.Endereco.CEP := SoNumeros(AEmitente.Endereco.CEP);
  AEmitente.Telefone := SoNumeros(AEmitente.Telefone);
  AEmitente.Endereco.UF := UpperCase(Trim(AEmitente.Endereco.UF));

  if Trim(AEmitente.RazaoSocial) = '' then
    raise EValidacao.Create('Informe a razão social');
  if not CnpjValido(AEmitente.CNPJ) then
    raise EValidacao.Create('CNPJ inválido');
  if Trim(AEmitente.IE) = '' then
    raise EValidacao.Create('Informe a inscrição estadual (ou ISENTO)');
  if Length(AEmitente.Endereco.UF) <> 2 then
    raise EValidacao.Create('Informe a UF');
  if Length(IntToStr(AEmitente.Endereco.CodigoMunicipio)) <> 7 then
    raise EValidacao.Create('Código do município (IBGE) deve ter 7 dígitos');
  if Length(AEmitente.Endereco.CEP) <> 8 then
    raise EValidacao.Create('CEP deve ter 8 dígitos');
  if (AEmitente.Email <> '') and not EmailValido(AEmitente.Email) then
    raise EValidacao.Create('E-mail inválido');
  if (AEmitente.SerieNFe < 0) or (AEmitente.SerieNFe > 889) or
     (AEmitente.SerieNFCe < 0) or (AEmitente.SerieNFCe > 889) then
    raise EValidacao.Create('Série deve estar entre 0 e 889');
  if (AEmitente.ProximoNumeroNFe < 1) or (AEmitente.ProximoNumeroNFCe < 1) then
    raise EValidacao.Create('Próximo número deve ser maior que zero');

  FRepo.Salvar(AEmitente);
end;

end.
