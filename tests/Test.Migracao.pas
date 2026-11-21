unit Test.Migracao;

interface

uses
  System.Classes, DUnitX.TestFramework;

type
  [TestFixture]
  TTestMigracao = class
  private
    FAplicados: TStringList;
    function Prefixos(const AArquivos: TArray<string>): string;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    [Test]
    procedure Pendentes_OrdenaPeloNomeDoArquivo;
    [Test]
    procedure Pendentes_IgnoraJaAplicados;
    [Test]
    procedure Pendentes_NomeSemDiferenciarMaiusculas;
    [Test]
    procedure Pendentes_SeedsDesligados_PulaSeeds;
    [Test]
    procedure Pendentes_SeedPuladoRodaQuandoLigar;
    [Test]
    procedure Pendentes_TudoAplicado_RetornaVazio;

    [Test]
    [TestCase('Seed', 'database\003_seed_dados_exemplo.sql,True')]
    [TestCase('Maiusculas', '005_SEED_mais_produtos.sql,True')]
    [TestCase('Tabela', 'database\001_create_tables.sql,False')]
    [TestCase('SeedSoNaPasta', 'C:\_seed_\004_alter_nota.sql,False')]
    procedure EhSeed(const AArquivo: string; AEsperado: Boolean);
  end;

implementation

uses
  System.SysUtils, Infra.Migracao;

const
  SCRIPTS: TArray<string> = [
    'database\003_seed_dados_exemplo.sql',
    'database\001_create_tables.sql',
    'database\004_alter_nota.sql',
    'database\002_formas_pagamento.sql'];

procedure TTestMigracao.Setup;
begin
  FAplicados := TStringList.Create;
  FAplicados.CaseSensitive := False;
end;

procedure TTestMigracao.TearDown;
begin
  FAplicados.Free;
end;

function TTestMigracao.Prefixos(const AArquivos: TArray<string>): string;
var
  LArquivo: string;
begin
  Result := '';
  for LArquivo in AArquivos do
  begin
    if Result <> '' then
      Result := Result + ',';
    Result := Result + Copy(ExtractFileName(LArquivo), 1, 3);
  end;
end;

procedure TTestMigracao.Pendentes_OrdenaPeloNomeDoArquivo;
begin
  Assert.AreEqual('001,002,003,004', Prefixos(TMigrador.ScriptsPendentes(SCRIPTS, FAplicados, True)));
end;

procedure TTestMigracao.Pendentes_IgnoraJaAplicados;
begin
  FAplicados.Add('001_create_tables.sql');
  FAplicados.Add('002_formas_pagamento.sql');
  Assert.AreEqual('003,004', Prefixos(TMigrador.ScriptsPendentes(SCRIPTS, FAplicados, True)));
end;

procedure TTestMigracao.Pendentes_NomeSemDiferenciarMaiusculas;
begin
  FAplicados.Add('001_CREATE_TABLES.SQL');
  Assert.AreEqual('002,003,004', Prefixos(TMigrador.ScriptsPendentes(SCRIPTS, FAplicados, True)));
end;

procedure TTestMigracao.Pendentes_SeedsDesligados_PulaSeeds;
begin
  Assert.AreEqual('001,002,004', Prefixos(TMigrador.ScriptsPendentes(SCRIPTS, FAplicados, False)));
end;

procedure TTestMigracao.Pendentes_SeedPuladoRodaQuandoLigar;
begin
  // seed pulado não fica registrado, então entra quando ExecutarSeeds é ligado
  FAplicados.Add('001_create_tables.sql');
  FAplicados.Add('002_formas_pagamento.sql');
  FAplicados.Add('004_alter_nota.sql');
  Assert.AreEqual('003', Prefixos(TMigrador.ScriptsPendentes(SCRIPTS, FAplicados, True)));
end;

procedure TTestMigracao.Pendentes_TudoAplicado_RetornaVazio;
var
  LScript: string;
begin
  for LScript in SCRIPTS do
    FAplicados.Add(ExtractFileName(LScript));
  Assert.AreEqual(0, Length(TMigrador.ScriptsPendentes(SCRIPTS, FAplicados, True)));
end;

procedure TTestMigracao.EhSeed(const AArquivo: string; AEsperado: Boolean);
begin
  Assert.AreEqual(AEsperado, TMigrador.EhSeed(AArquivo));
end;

initialization
  TDUnitX.RegisterTestFixture(TTestMigracao);

end.
