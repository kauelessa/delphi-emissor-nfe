unit Service.Calculo;

{
  Cálculos da nota: valor dos itens, rateio do desconto, ICMS, PIS/COFINS e
  totais. Tudo em Currency e arredondado em 2 casas, como o XML da NF-e exige.

  Escopo tributário (suficiente para varejo no Simples ou regime normal sem ST):
  - ICMS próprio só é destacado para CST 00 (tributada integralmente) e
    CST 20 (com redução de base). CSOSN do Simples não destaca ICMS.
  - PIS/COFINS calculados por alíquota para CST 01 e 02.
  - Sem frete, seguro, IPI ou ICMS-ST.
}

interface

uses
  Model.Nota, Model.ItemNota;

type
  TCalculoNota = class
  public
    /// Arredondamento comercial (metade para cima), usado pela SEFAZ na
    /// validação de vProd = qCom x vUnCom (tolerância de 1 centavo).
    class function Arredondar(AValor: Extended; ACasas: Integer = 2): Currency; static;

    class function CalculaICMS(const ACst: string): Boolean; static;
    class function CalculaPisCofins(const ACst: string): Boolean; static;

    class procedure CalcularItem(AItem: TItemNota); static;

    /// Distribui o desconto da nota entre os itens, proporcional ao valor de
    /// cada um. A sobra de centavos do arredondamento vai para o item de maior
    /// valor, assim a soma dos vDesc dos itens bate exatamente com o total.
    class procedure RatearDesconto(ANota: TNota; ADesconto: Currency); static;

    /// Recalcula itens e totais. Deve ser chamado sempre que itens, desconto
    /// ou pagamentos mudarem.
    class procedure CalcularTotais(ANota: TNota); static;
  end;

implementation

uses
  System.SysUtils, System.Math, Model.Tipos;

{ TCalculoNota }

class function TCalculoNota.Arredondar(AValor: Extended; ACasas: Integer): Currency;
var
  LFator: Extended;
begin
  LFator := IntPower(10, ACasas);
  // o 1E-9 absorve o erro de representação binária (ex.: 2,675 vira 2,67499999...)
  if AValor >= 0 then
    Result := Trunc(AValor * LFator + 0.5 + 1E-9) / LFator
  else
    Result := -(Trunc(-AValor * LFator + 0.5 + 1E-9) / LFator);
end;

class function TCalculoNota.CalculaICMS(const ACst: string): Boolean;
begin
  Result := (ACst = '00') or (ACst = '20');
end;

class function TCalculoNota.CalculaPisCofins(const ACst: string): Boolean;
begin
  Result := (ACst = '01') or (ACst = '02');
end;

class procedure TCalculoNota.CalcularItem(AItem: TItemNota);
var
  LBase: Currency;
begin
  AItem.ValorProduto := Arredondar(AItem.Quantidade * AItem.ValorUnitario);
  if AItem.ValorDesconto > AItem.ValorProduto then
    raise EValidacao.CreateFmt('Desconto do item %d maior que o valor do item', [AItem.NumeroItem]);

  AItem.ValorTotal := AItem.ValorProduto - AItem.ValorDesconto;

  if CalculaICMS(AItem.CstCsosn) then
  begin
    LBase := AItem.ValorTotal;
    if (AItem.CstCsosn = '20') and (AItem.ReducaoBaseICMS > 0) then
      LBase := Arredondar(LBase * (1 - AItem.ReducaoBaseICMS / 100));
    AItem.BaseICMS := LBase;
    AItem.ValorICMS := Arredondar(LBase * AItem.AliquotaICMS / 100);
  end
  else
  begin
    AItem.BaseICMS := 0;
    AItem.ValorICMS := 0;
  end;

  if CalculaPisCofins(AItem.CstPIS) then
  begin
    AItem.BasePIS := AItem.ValorTotal;
    AItem.ValorPIS := Arredondar(AItem.BasePIS * AItem.AliquotaPIS / 100);
  end
  else
  begin
    AItem.BasePIS := 0;
    AItem.ValorPIS := 0;
  end;

  if CalculaPisCofins(AItem.CstCOFINS) then
  begin
    AItem.BaseCOFINS := AItem.ValorTotal;
    AItem.ValorCOFINS := Arredondar(AItem.BaseCOFINS * AItem.AliquotaCOFINS / 100);
  end
  else
  begin
    AItem.BaseCOFINS := 0;
    AItem.ValorCOFINS := 0;
  end;
end;

class procedure TCalculoNota.RatearDesconto(ANota: TNota; ADesconto: Currency);
var
  LItem, LMaior: TItemNota;
  LTotalProdutos, LDistribuido: Currency;
begin
  if ADesconto < 0 then
    raise EValidacao.Create('Desconto não pode ser negativo');

  LTotalProdutos := 0;
  LMaior := nil;
  for LItem in ANota.Itens do
  begin
    LItem.ValorProduto := Arredondar(LItem.Quantidade * LItem.ValorUnitario);
    LTotalProdutos := LTotalProdutos + LItem.ValorProduto;
    if (LMaior = nil) or (LItem.ValorProduto > LMaior.ValorProduto) then
      LMaior := LItem;
  end;

  if ADesconto = 0 then
  begin
    for LItem in ANota.Itens do
      LItem.ValorDesconto := 0;
    Exit;
  end;

  if ANota.Itens.Count = 0 then
    raise EValidacao.Create('Adicione itens antes de aplicar desconto');
  if ADesconto >= LTotalProdutos then
    raise EValidacao.Create('Desconto deve ser menor que o total dos produtos');

  LDistribuido := 0;
  for LItem in ANota.Itens do
  begin
    if LItem = LMaior then
      Continue;
    LItem.ValorDesconto := Arredondar(ADesconto * LItem.ValorProduto / LTotalProdutos);
    LDistribuido := LDistribuido + LItem.ValorDesconto;
  end;
  if LMaior <> nil then
    LMaior.ValorDesconto := ADesconto - LDistribuido;
end;

class procedure TCalculoNota.CalcularTotais(ANota: TNota);
var
  LItem: TItemNota;
  I: Integer;
begin
  ANota.ValorProdutos := 0;
  ANota.ValorDesconto := 0;
  ANota.BaseICMS := 0;
  ANota.ValorICMS := 0;
  ANota.ValorPIS := 0;
  ANota.ValorCOFINS := 0;

  for I := 0 to ANota.Itens.Count - 1 do
  begin
    LItem := ANota.Itens[I];
    LItem.NumeroItem := I + 1;
    CalcularItem(LItem);
    ANota.ValorProdutos := ANota.ValorProdutos + LItem.ValorProduto;
    ANota.ValorDesconto := ANota.ValorDesconto + LItem.ValorDesconto;
    ANota.BaseICMS := ANota.BaseICMS + LItem.BaseICMS;
    ANota.ValorICMS := ANota.ValorICMS + LItem.ValorICMS;
    ANota.ValorPIS := ANota.ValorPIS + LItem.ValorPIS;
    ANota.ValorCOFINS := ANota.ValorCOFINS + LItem.ValorCOFINS;
  end;

  ANota.ValorTotal := ANota.ValorProdutos - ANota.ValorDesconto;
  ANota.ValorTroco := Max(ANota.TotalPago - ANota.ValorTotal, 0);
end;

end.
