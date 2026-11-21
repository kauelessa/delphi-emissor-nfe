unit Service.Cliente;

interface

uses
  System.Generics.Collections, Model.Cliente, Repository.Cliente;

type
  IClienteService = interface
    ['{4D5E6F7A-8B9C-4D0E-1F2A-3B4C5D6E7F80}']
    function Listar(const AFiltro: string): TObjectList<TCliente>;
    function Obter(AId: Integer): TCliente;
    procedure Salvar(ACliente: TCliente);
    procedure Inativar(AId: Integer);
  end;

  TClienteService = class(TInterfacedObject, IClienteService)
  private
    FRepo: IClienteRepository;
  public
    constructor Create(ARepo: IClienteRepository);
    function Listar(const AFiltro: string): TObjectList<TCliente>;
    function Obter(AId: Integer): TCliente;
    procedure Salvar(ACliente: TCliente);
    procedure Inativar(AId: Integer);
  end;

implementation

uses
  System.SysUtils, Model.Tipos, Infra.Documento;

constructor TClienteService.Create(ARepo: IClienteRepository);
begin
  inherited Create;
  FRepo := ARepo;
end;

function TClienteService.Listar(const AFiltro: string): TObjectList<TCliente>;
begin
  Result := FRepo.Listar(AFiltro);
end;

function TClienteService.Obter(AId: Integer): TCliente;
begin
  Result := FRepo.Obter(AId);
end;

procedure TClienteService.Salvar(ACliente: TCliente);
begin
  ACliente.Nome := Trim(ACliente.Nome);
  ACliente.CpfCnpj := SoNumeros(ACliente.CpfCnpj);
  ACliente.Telefone := SoNumeros(ACliente.Telefone);
  ACliente.Endereco.CEP := SoNumeros(ACliente.Endereco.CEP);
  ACliente.Endereco.UF := UpperCase(Trim(ACliente.Endereco.UF));

  if Length(ACliente.Nome) < 2 then
    raise EValidacao.Create('Informe o nome do cliente');
  if not CpfCnpjValido(ACliente.CpfCnpj) then
    raise EValidacao.Create('CPF/CNPJ inválido');
  if (ACliente.IndicadorIE = TIndicadorIE.Contribuinte) and (Trim(ACliente.IE) = '') then
    raise EValidacao.Create('Contribuinte de ICMS precisa ter inscrição estadual');
  // pessoa física não é contribuinte (salvo produtor rural, fora do escopo aqui)
  if not ACliente.PessoaJuridica and (ACliente.IndicadorIE = TIndicadorIE.Contribuinte) then
    raise EValidacao.Create('CPF não pode ser contribuinte de ICMS');
  if (ACliente.Email <> '') and not EmailValido(ACliente.Email) then
    raise EValidacao.Create('E-mail inválido');

  // endereço é opcional (NFC-e), mas se começou a preencher tem que estar coerente
  if ACliente.Endereco.Logradouro <> '' then
  begin
    if Length(ACliente.Endereco.UF) <> 2 then
      raise EValidacao.Create('Informe a UF');
    if Length(IntToStr(ACliente.Endereco.CodigoMunicipio)) <> 7 then
      raise EValidacao.Create('Código do município (IBGE) deve ter 7 dígitos');
    if (ACliente.Endereco.CEP <> '') and (Length(ACliente.Endereco.CEP) <> 8) then
      raise EValidacao.Create('CEP deve ter 8 dígitos');
  end;

  FRepo.Salvar(ACliente);
end;

procedure TClienteService.Inativar(AId: Integer);
begin
  FRepo.Inativar(AId);
end;

end.
