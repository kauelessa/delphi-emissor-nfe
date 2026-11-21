unit Test.Documento;

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TTestDocumento = class
  public
    [Test]
    [TestCase('com máscara', '529.982.247-25,True')]
    [TestCase('sem máscara', '52998224725,True')]
    [TestCase('dígito errado', '52998224724,False')]
    [TestCase('repetido', '111.111.111-11,False')]
    [TestCase('curto', '5299822472,False')]
    procedure CpfValido(const ACpf: string; AEsperado: Boolean);

    [Test]
    [TestCase('com máscara', '11.222.333/0001-81,True')]
    [TestCase('sem máscara', '11222333000181,True')]
    [TestCase('dígito errado', '11222333000180,False')]
    [TestCase('repetido', '00000000000000,False')]
    procedure CnpjValido(const ACnpj: string; AEsperado: Boolean);

    [Test]
    [TestCase('EAN-13', '4006381333931,True')]
    [TestCase('EAN-8', '96385074,True')]
    [TestCase('SEM GTIN', 'SEM GTIN,True')]
    [TestCase('dígito errado', '4006381333932,False')]
    [TestCase('tamanho inválido', '123456789,False')]
    [TestCase('com letra', '40063813339A1,False')]
    procedure GtinValido(const AGtin: string; AEsperado: Boolean);

    [Test]
    [TestCase('válido', 'cliente@exemplo.com.br,True')]
    [TestCase('sem arroba', 'cliente.exemplo.com,False')]
    [TestCase('sem domínio', 'cliente@,False')]
    [TestCase('com espaço', 'cli ente@exemplo.com,False')]
    procedure EmailValido(const AEmail: string; AEsperado: Boolean);

    [Test]
    procedure FormatarCpfCnpj_AplicaMascara;
  end;

implementation

uses
  Infra.Documento;

procedure TTestDocumento.CpfValido(const ACpf: string; AEsperado: Boolean);
begin
  Assert.AreEqual(AEsperado, Infra.Documento.CpfValido(ACpf));
end;

procedure TTestDocumento.CnpjValido(const ACnpj: string; AEsperado: Boolean);
begin
  Assert.AreEqual(AEsperado, Infra.Documento.CnpjValido(ACnpj));
end;

procedure TTestDocumento.GtinValido(const AGtin: string; AEsperado: Boolean);
begin
  Assert.AreEqual(AEsperado, Infra.Documento.GtinValido(AGtin));
end;

procedure TTestDocumento.EmailValido(const AEmail: string; AEsperado: Boolean);
begin
  Assert.AreEqual(AEsperado, Infra.Documento.EmailValido(AEmail));
end;

procedure TTestDocumento.FormatarCpfCnpj_AplicaMascara;
begin
  Assert.AreEqual('529.982.247-25', FormatarCpfCnpj('52998224725'));
  Assert.AreEqual('11.222.333/0001-81', FormatarCpfCnpj('11222333000181'));
end;

initialization
  TDUnitX.RegisterTestFixture(TTestDocumento);

end.
