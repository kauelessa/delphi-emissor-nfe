unit Test.RetornoSefaz;

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TTestRetornoSefaz = class
  public
    [Test]
    [TestCase('autorizado', '100,0')]
    [TestCase('autorizado fora do prazo', '150,0')]
    [TestCase('denegado', '110,1')]
    [TestCase('denegado emitente irregular', '301,1')]
    [TestCase('duplicidade', '204,2')]
    [TestCase('lote em processamento', '105,3')]
    [TestCase('rejeição NCM', '778,4')]
    [TestCase('rejeição emitente sem cadastro', '245,4')]
    [TestCase('evento registrado', '135,5')]
    [TestCase('inutilização homologada', '102,6')]
    [TestCase('serviço em operação', '107,7')]
    [TestCase('serviço paralisado', '108,8')]
    [TestCase('sem resposta', '0,9')]
    procedure Situacao(ACStat, ASituacaoEsperada: Integer);

    [Test]
    procedure Mensagem_RejeicaoConhecida_IncluiOrientacao;
    [Test]
    procedure Mensagem_EmitenteSemInscricaoEstadual_ExplicaIE;
    [Test]
    procedure Mensagem_RejeicaoDesconhecida_MostraSoCodigoEMotivo;
  end;

implementation

uses
  System.SysUtils, Service.RetornoSefaz;

procedure TTestRetornoSefaz.Situacao(ACStat, ASituacaoEsperada: Integer);
begin
  Assert.AreEqual<Integer>(ASituacaoEsperada, Ord(TRetornoSefaz.Situacao(ACStat)));
end;

procedure TTestRetornoSefaz.Mensagem_RejeicaoConhecida_IncluiOrientacao;
var
  LMensagem: string;
begin
  LMensagem := TRetornoSefaz.Mensagem(778, 'Rejeicao: Informado NCM inexistente');
  Assert.StartsWith('778 - Rejeicao: Informado NCM inexistente', LMensagem);
  Assert.Contains(LMensagem, 'cadastro do produto');
end;

procedure TTestRetornoSefaz.Mensagem_EmitenteSemInscricaoEstadual_ExplicaIE;
begin
  Assert.Contains(TRetornoSefaz.Mensagem(245, 'Rejeicao: CNPJ Emitente nao cadastrado'),
    'inscrição estadual');
end;

procedure TTestRetornoSefaz.Mensagem_RejeicaoDesconhecida_MostraSoCodigoEMotivo;
begin
  Assert.AreEqual('999 - Rejeicao: Erro nao catalogado',
    TRetornoSefaz.Mensagem(999, 'Rejeicao: Erro nao catalogado'));
end;

initialization
  TDUnitX.RegisterTestFixture(TTestRetornoSefaz);

end.
