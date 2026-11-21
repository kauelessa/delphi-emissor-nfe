unit Service.FormaPagamento;

interface

uses
  System.Generics.Collections, Model.FormaPagamento, Repository.FormaPagamento;

type
  IFormaPagamentoService = interface
    ['{6F7A8B9C-0D1E-4F2A-3B4C-5D6E7F8091A2}']
    function Listar(AApenasAtivas: Boolean = True): TObjectList<TFormaPagamento>;
    function Obter(AId: Integer): TFormaPagamento;
    procedure Salvar(AForma: TFormaPagamento);
  end;

  TFormaPagamentoService = class(TInterfacedObject, IFormaPagamentoService)
  private
    FRepo: IFormaPagamentoRepository;
  public
    constructor Create(ARepo: IFormaPagamentoRepository);
    function Listar(AApenasAtivas: Boolean = True): TObjectList<TFormaPagamento>;
    function Obter(AId: Integer): TFormaPagamento;
    procedure Salvar(AForma: TFormaPagamento);
  end;

implementation

uses
  System.SysUtils, Model.Tipos;

constructor TFormaPagamentoService.Create(ARepo: IFormaPagamentoRepository);
begin
  inherited Create;
  FRepo := ARepo;
end;

function TFormaPagamentoService.Listar(AApenasAtivas: Boolean): TObjectList<TFormaPagamento>;
begin
  Result := FRepo.Listar(AApenasAtivas);
end;

function TFormaPagamentoService.Obter(AId: Integer): TFormaPagamento;
begin
  Result := FRepo.Obter(AId);
end;

procedure TFormaPagamentoService.Salvar(AForma: TFormaPagamento);
var
  I: Integer;
  LCodigoValido: Boolean;
begin
  AForma.Descricao := Trim(AForma.Descricao);
  if AForma.Descricao = '' then
    raise EValidacao.Create('Informe a descrição');

  LCodigoValido := False;
  for I := Low(FORMAS_PAGAMENTO_SEFAZ) to High(FORMAS_PAGAMENTO_SEFAZ) do
    if FORMAS_PAGAMENTO_SEFAZ[I][0] = AForma.CodigoSefaz then
      LCodigoValido := True;
  if not LCodigoValido then
    raise EValidacao.Create('Selecione o código da SEFAZ (tPag)');

  FRepo.Salvar(AForma);
end;

end.
