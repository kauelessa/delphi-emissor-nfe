unit Test.Calculo;

interface

uses
  DUnitX.TestFramework, Model.Nota, Model.ItemNota;

type
  [TestFixture]
  TTestCalculo = class
  private
    function NovoItem(AQuantidade, AValorUnitario: Currency; const ACst: string = '102'): TItemNota;
  public
    [Test]
    [TestCase('2,675 sobe', '2.675,2.68')]
    [TestCase('1,005 sobe', '1.005,1.01')]
    [TestCase('10,004 desce', '10.004,10')]
    [TestCase('negativo', '-2.675,-2.68')]
    [TestCase('exato', '7.5,7.5')]
    procedure Arredondar_DuasCasas(AValor, AEsperado: Extended);

    [Test]
    procedure CalcularItem_ValorProduto_ArredondaQuantidadeVezesUnitario;
    [Test]
    procedure CalcularItem_Cst00_DestacaICMS;
    [Test]
    procedure CalcularItem_Cst20_AplicaReducaoDeBase;
    [Test]
    procedure CalcularItem_Csosn102_NaoDestacaICMS;
    [Test]
    procedure CalcularItem_PisCofinsCst01_CalculaPorAliquota;
    [Test]
    procedure CalcularItem_DescontoMaiorQueItem_LevantaExcecao;

    [Test]
    procedure RatearDesconto_Proporcional_SomaBateComTotal;
    [Test]
    procedure RatearDesconto_CentavoIndivisivel_VaiParaMaiorItem;
    [Test]
    procedure RatearDesconto_MaiorOuIgualAoTotal_LevantaExcecao;
    [Test]
    procedure RatearDesconto_Zero_LimpaDescontosAnteriores;

    [Test]
    procedure CalcularTotais_SomaItensDescontoETroco;
    [Test]
    procedure CalcularTotais_RenumeraItens;
  end;

implementation

uses
  System.SysUtils, Model.Tipos, Model.Pagamento, Service.Calculo;

function TTestCalculo.NovoItem(AQuantidade, AValorUnitario: Currency; const ACst: string): TItemNota;
begin
  Result := TItemNota.Create;
  Result.Quantidade := AQuantidade;
  Result.ValorUnitario := AValorUnitario;
  Result.CstCsosn := ACst;
  Result.CstPIS := '49';
  Result.CstCOFINS := '49';
end;

procedure TTestCalculo.Arredondar_DuasCasas(AValor, AEsperado: Extended);
begin
  Assert.AreEqual(Currency(AEsperado), TCalculoNota.Arredondar(AValor));
end;

procedure TTestCalculo.CalcularItem_ValorProduto_ArredondaQuantidadeVezesUnitario;
var
  LItem: TItemNota;
begin
  LItem := NovoItem(3, 33.3333);
  try
    TCalculoNota.CalcularItem(LItem);
    // 3 x 33,3333 = 99,9999 -> 100,00
    Assert.AreEqual(Currency(100.00), LItem.ValorProduto);
    Assert.AreEqual(Currency(100.00), LItem.ValorTotal);
  finally
    LItem.Free;
  end;
end;

procedure TTestCalculo.CalcularItem_Cst00_DestacaICMS;
var
  LItem: TItemNota;
begin
  LItem := NovoItem(2, 50, '00');
  try
    LItem.AliquotaICMS := 18;
    LItem.ValorDesconto := 10;
    TCalculoNota.CalcularItem(LItem);
    // base = 100 - 10 de desconto
    Assert.AreEqual(Currency(90.00), LItem.BaseICMS);
    Assert.AreEqual(Currency(16.20), LItem.ValorICMS);
  finally
    LItem.Free;
  end;
end;

procedure TTestCalculo.CalcularItem_Cst20_AplicaReducaoDeBase;
var
  LItem: TItemNota;
begin
  LItem := NovoItem(1, 100, '20');
  try
    LItem.AliquotaICMS := 18;
    LItem.ReducaoBaseICMS := 33.33;
    TCalculoNota.CalcularItem(LItem);
    Assert.AreEqual(Currency(66.67), LItem.BaseICMS);
    // 66,67 x 18% = 12,0006
    Assert.AreEqual(Currency(12.00), LItem.ValorICMS);
  finally
    LItem.Free;
  end;
end;

procedure TTestCalculo.CalcularItem_Csosn102_NaoDestacaICMS;
var
  LItem: TItemNota;
begin
  LItem := NovoItem(1, 100, '102');
  try
    LItem.AliquotaICMS := 18;
    TCalculoNota.CalcularItem(LItem);
    Assert.AreEqual(Currency(0), LItem.BaseICMS);
    Assert.AreEqual(Currency(0), LItem.ValorICMS);
  finally
    LItem.Free;
  end;
end;

procedure TTestCalculo.CalcularItem_PisCofinsCst01_CalculaPorAliquota;
var
  LItem: TItemNota;
begin
  LItem := NovoItem(1, 100, '00');
  try
    LItem.CstPIS := '01';
    LItem.AliquotaPIS := 1.65;
    LItem.CstCOFINS := '01';
    LItem.AliquotaCOFINS := 7.6;
    TCalculoNota.CalcularItem(LItem);
    Assert.AreEqual(Currency(1.65), LItem.ValorPIS);
    Assert.AreEqual(Currency(7.60), LItem.ValorCOFINS);
  finally
    LItem.Free;
  end;
end;

procedure TTestCalculo.CalcularItem_DescontoMaiorQueItem_LevantaExcecao;
var
  LItem: TItemNota;
begin
  LItem := NovoItem(1, 10);
  try
    LItem.ValorDesconto := 10.01;
    Assert.WillRaise(
      procedure
      begin
        TCalculoNota.CalcularItem(LItem);
      end, EValidacao);
  finally
    LItem.Free;
  end;
end;

procedure TTestCalculo.RatearDesconto_Proporcional_SomaBateComTotal;
var
  LNota: TNota;
begin
  LNota := TNota.Create;
  try
    LNota.Itens.Add(NovoItem(1, 10));
    LNota.Itens.Add(NovoItem(1, 20));
    LNota.Itens.Add(NovoItem(1, 30));
    TCalculoNota.RatearDesconto(LNota, 10);
    // 10 x 10/60 = 1,666 e 10 x 20/60 = 3,333; o maior item fica com a sobra
    Assert.AreEqual(Currency(1.67), LNota.Itens[0].ValorDesconto);
    Assert.AreEqual(Currency(3.33), LNota.Itens[1].ValorDesconto);
    Assert.AreEqual(Currency(5.00), LNota.Itens[2].ValorDesconto);

    TCalculoNota.CalcularTotais(LNota);
    Assert.AreEqual(Currency(10), LNota.ValorDesconto);
    Assert.AreEqual(Currency(50), LNota.ValorTotal);
  finally
    LNota.Free;
  end;
end;

procedure TTestCalculo.RatearDesconto_CentavoIndivisivel_VaiParaMaiorItem;
var
  LNota: TNota;
begin
  LNota := TNota.Create;
  try
    LNota.Itens.Add(NovoItem(1, 10));
    LNota.Itens.Add(NovoItem(1, 10));
    LNota.Itens.Add(NovoItem(1, 10));
    TCalculoNota.RatearDesconto(LNota, 0.01);
    Assert.AreEqual(Currency(0.01), LNota.Itens[0].ValorDesconto + LNota.Itens[1].ValorDesconto +
      LNota.Itens[2].ValorDesconto);
  finally
    LNota.Free;
  end;
end;

procedure TTestCalculo.RatearDesconto_MaiorOuIgualAoTotal_LevantaExcecao;
var
  LNota: TNota;
begin
  LNota := TNota.Create;
  try
    LNota.Itens.Add(NovoItem(2, 5));
    Assert.WillRaise(
      procedure
      begin
        TCalculoNota.RatearDesconto(LNota, 10);
      end, EValidacao);
  finally
    LNota.Free;
  end;
end;

procedure TTestCalculo.RatearDesconto_Zero_LimpaDescontosAnteriores;
var
  LNota: TNota;
begin
  LNota := TNota.Create;
  try
    LNota.Itens.Add(NovoItem(1, 10));
    LNota.Itens[0].ValorDesconto := 3;
    TCalculoNota.RatearDesconto(LNota, 0);
    Assert.AreEqual(Currency(0), LNota.Itens[0].ValorDesconto);
  finally
    LNota.Free;
  end;
end;

procedure TTestCalculo.CalcularTotais_SomaItensDescontoETroco;
var
  LNota: TNota;
  LPagamento: TPagamentoNota;
begin
  LNota := TNota.Create;
  try
    LNota.Itens.Add(NovoItem(2, 49.90));
    LNota.Itens.Add(NovoItem(1, 18.75));
    TCalculoNota.RatearDesconto(LNota, 8.55);

    LPagamento := TPagamentoNota.Create;
    LPagamento.Valor := 150;
    LNota.Pagamentos.Add(LPagamento);

    TCalculoNota.CalcularTotais(LNota);
    Assert.AreEqual(Currency(118.55), LNota.ValorProdutos);
    Assert.AreEqual(Currency(8.55), LNota.ValorDesconto);
    Assert.AreEqual(Currency(110.00), LNota.ValorTotal);
    Assert.AreEqual(Currency(40.00), LNota.ValorTroco);
  finally
    LNota.Free;
  end;
end;

procedure TTestCalculo.CalcularTotais_RenumeraItens;
var
  LNota: TNota;
begin
  LNota := TNota.Create;
  try
    LNota.Itens.Add(NovoItem(1, 1));
    LNota.Itens.Add(NovoItem(1, 2));
    LNota.Itens[0].NumeroItem := 7;
    TCalculoNota.CalcularTotais(LNota);
    Assert.AreEqual(1, LNota.Itens[0].NumeroItem);
    Assert.AreEqual(2, LNota.Itens[1].NumeroItem);
  finally
    LNota.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TTestCalculo);

end.
