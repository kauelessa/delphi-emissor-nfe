unit Infra.Log;

{
  Log em arquivo texto, um arquivo por dia (logs\AAAA-MM-DD.log).
  As operações fiscais usam o nível "FISCAL" para ficar fácil filtrar depois.
  A escrita é protegida por TMonitor porque o envio de e-mail e a impressão
  do ACBr podem disparar callbacks fora da thread principal.
}

interface

type
  TNivelLog = (Info, Aviso, Erro, Fiscal);

  ILog = interface
    ['{F2D8C3B4-71A5-4B9E-8F0C-5E6D7A8B9C01}']
    procedure Registrar(ANivel: TNivelLog; const AMensagem: string);
    procedure Info(const AMensagem: string);
    procedure Erro(const AMensagem: string);
    procedure Fiscal(const AMensagem: string);
  end;

  TLogArquivo = class(TInterfacedObject, ILog)
  private
    FPasta: string;
    FTrava: TObject;
  public
    constructor Create(const APasta: string);
    destructor Destroy; override;
    procedure Registrar(ANivel: TNivelLog; const AMensagem: string);
    procedure Info(const AMensagem: string);
    procedure Erro(const AMensagem: string);
    procedure Fiscal(const AMensagem: string);
  end;

function Log: ILog;

implementation

uses
  System.SysUtils, System.Classes, System.IOUtils, Infra.Config;

const
  NOMES_NIVEL: array[TNivelLog] of string = ('INFO', 'AVISO', 'ERRO', 'FISCAL');

var
  GLog: ILog;

function Log: ILog;
begin
  if GLog = nil then
    GLog := TLogArquivo.Create(Config.PastaLog);
  Result := GLog;
end;

{ TLogArquivo }

constructor TLogArquivo.Create(const APasta: string);
begin
  inherited Create;
  FPasta := APasta;
  FTrava := TObject.Create;
end;

destructor TLogArquivo.Destroy;
begin
  FTrava.Free;
  inherited;
end;

procedure TLogArquivo.Registrar(ANivel: TNivelLog; const AMensagem: string);
var
  LArquivo, LLinha: string;
begin
  LLinha := Format('%s [%s] %s', [FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', Now),
    NOMES_NIVEL[ANivel], AMensagem]) + sLineBreak;

  TMonitor.Enter(FTrava);
  try
    try
      ForceDirectories(FPasta);
      LArquivo := TPath.Combine(FPasta, FormatDateTime('yyyy-mm-dd', Date) + '.log');
      TFile.AppendAllText(LArquivo, LLinha, TEncoding.UTF8);
    except
      // falha ao gravar log não pode derrubar a emissão da nota
    end;
  finally
    TMonitor.Exit(FTrava);
  end;
end;

procedure TLogArquivo.Info(const AMensagem: string);
begin
  Registrar(TNivelLog.Info, AMensagem);
end;

procedure TLogArquivo.Erro(const AMensagem: string);
begin
  Registrar(TNivelLog.Erro, AMensagem);
end;

procedure TLogArquivo.Fiscal(const AMensagem: string);
begin
  Registrar(TNivelLog.Fiscal, AMensagem);
end;

initialization

finalization
  GLog := nil;

end.
