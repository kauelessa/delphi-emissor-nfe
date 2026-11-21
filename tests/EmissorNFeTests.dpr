program EmissorNFeTests;

{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}

uses
  System.SysUtils,
  DUnitX.Loggers.Console,
  DUnitX.Loggers.Xml.NUnit,
  DUnitX.TestFramework,
  Model.Tipos in '..\src\Models\Model.Tipos.pas',
  Model.Endereco in '..\src\Models\Model.Endereco.pas',
  Model.Emitente in '..\src\Models\Model.Emitente.pas',
  Model.Cliente in '..\src\Models\Model.Cliente.pas',
  Model.Produto in '..\src\Models\Model.Produto.pas',
  Model.FormaPagamento in '..\src\Models\Model.FormaPagamento.pas',
  Model.ItemNota in '..\src\Models\Model.ItemNota.pas',
  Model.Pagamento in '..\src\Models\Model.Pagamento.pas',
  Model.Nota in '..\src\Models\Model.Nota.pas',
  Model.EventoFiscal in '..\src\Models\Model.EventoFiscal.pas',
  Infra.Config in '..\src\Infra\Infra.Config.pas',
  Infra.Conexao in '..\src\Infra\Infra.Conexao.pas',
  Infra.Log in '..\src\Infra\Infra.Log.pas',
  Infra.Documento in '..\src\Infra\Infra.Documento.pas',
  Infra.ArquivoXml in '..\src\Infra\Infra.ArquivoXml.pas',
  Infra.Migracao in '..\src\Infra\Infra.Migracao.pas',
  Repository.Emitente in '..\src\Repositories\Repository.Emitente.pas',
  Repository.Cliente in '..\src\Repositories\Repository.Cliente.pas',
  Repository.Produto in '..\src\Repositories\Repository.Produto.pas',
  Repository.FormaPagamento in '..\src\Repositories\Repository.FormaPagamento.pas',
  Repository.Nota in '..\src\Repositories\Repository.Nota.pas',
  Repository.EventoFiscal in '..\src\Repositories\Repository.EventoFiscal.pas',
  Service.Calculo in '..\src\Services\Service.Calculo.pas',
  Service.RetornoSefaz in '..\src\Services\Service.RetornoSefaz.pas',
  Service.EmissorFiscal in '..\src\Services\Service.EmissorFiscal.pas',
  Service.Nota in '..\src\Services\Service.Nota.pas',
  Test.Fakes in 'Test.Fakes.pas',
  Test.Calculo in 'Test.Calculo.pas',
  Test.Documento in 'Test.Documento.pas',
  Test.RetornoSefaz in 'Test.RetornoSefaz.pas',
  Test.NotaService in 'Test.NotaService.pas',
  Test.Migracao in 'Test.Migracao.pas';

var
  LRunner: ITestRunner;
  LResultados: IRunResults;
begin
  try
    TDUnitX.CheckCommandLine;
    LRunner := TDUnitX.CreateRunner;
    LRunner.UseRTTI := True;
    LRunner.FailsOnNoAsserts := False;
    LRunner.AddLogger(TDUnitXConsoleLogger.Create(True));
    LRunner.AddLogger(TDUnitXXMLNUnitFileLogger.Create(TDUnitX.Options.XMLOutputFile));

    LResultados := LRunner.Execute;
    if not LResultados.AllPassed then
      System.ExitCode := EXIT_ERRORS;

    if TDUnitX.Options.ExitBehavior = TDUnitXExitBehavior.Pause then
    begin
      System.Write('Pressione <Enter> para sair.');
      System.Readln;
    end;
  except
    on E: Exception do
    begin
      System.Writeln(E.ClassName, ': ', E.Message);
      System.ExitCode := EXIT_ERRORS;
    end;
  end;
end.
