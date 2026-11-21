unit Model.Tipos;

interface

uses
  System.SysUtils;

{$SCOPEDENUMS ON}

const
  // limites do leiaute da NF-e para justificativas e eventos
  JUSTIFICATIVA_MINIMO = 15;
  JUSTIFICATIVA_MAXIMO = 255;
  CORRECAO_MAXIMO = 1000;
  MAXIMO_CCE = 20;
  MAXIMO_ITENS = 990;

type
  EValidacao = class(Exception);

  TModeloNota = (NFe, NFCe);

  TStatusNota = (Digitacao, Autorizada, Rejeitada, Denegada, Cancelada, Contingencia);

  TAmbienteFiscal = (Homologacao, Producao);

  // CRT da NF-e: 1 Simples Nacional, 2 Simples com excesso de sublimite, 3 Regime normal
  TRegimeTributario = (SimplesNacional, SimplesExcesso, RegimeNormal);

  // indIEDest: 1 contribuinte, 2 isento, 9 não contribuinte
  TIndicadorIE = (Contribuinte, Isento, NaoContribuinte);

  TTipoEventoFiscal = (Emissao, Cancelamento, CartaCorrecao, Inutilizacao, Contingencia);

  TModeloNotaHelper = record helper for TModeloNota
    function Codigo: Integer;
    function Descricao: string;
    class function DeCodigo(ACodigo: Integer): TModeloNota; static;
  end;

  TStatusNotaHelper = record helper for TStatusNota
    function Descricao: string;
  end;

  TRegimeTributarioHelper = record helper for TRegimeTributario
    function Codigo: Integer;
    function Descricao: string;
    function EhSimples: Boolean;
    class function DeCodigo(ACodigo: Integer): TRegimeTributario; static;
  end;

  TIndicadorIEHelper = record helper for TIndicadorIE
    function Codigo: Integer;
    function Descricao: string;
    class function DeCodigo(ACodigo: Integer): TIndicadorIE; static;
  end;

  TTipoEventoFiscalHelper = record helper for TTipoEventoFiscal
    function Descricao: string;
  end;

  // resultado devolvido pelos services para a tela
  TResultadoOperacao = record
    Sucesso: Boolean;
    Mensagem: string;
    class function Ok(const AMensagem: string): TResultadoOperacao; static;
    class function Falha(const AMensagem: string): TResultadoOperacao; static;
  end;

implementation

{ TModeloNotaHelper }

function TModeloNotaHelper.Codigo: Integer;
begin
  if Self = TModeloNota.NFCe then
    Result := 65
  else
    Result := 55;
end;

function TModeloNotaHelper.Descricao: string;
begin
  if Self = TModeloNota.NFCe then
    Result := 'NFC-e'
  else
    Result := 'NF-e';
end;

class function TModeloNotaHelper.DeCodigo(ACodigo: Integer): TModeloNota;
begin
  case ACodigo of
    55: Result := TModeloNota.NFe;
    65: Result := TModeloNota.NFCe;
  else
    raise EValidacao.CreateFmt('Modelo de nota inválido: %d', [ACodigo]);
  end;
end;

{ TStatusNotaHelper }

function TStatusNotaHelper.Descricao: string;
begin
  case Self of
    TStatusNota.Digitacao: Result := 'Em digitação';
    TStatusNota.Autorizada: Result := 'Autorizada';
    TStatusNota.Rejeitada: Result := 'Rejeitada';
    TStatusNota.Denegada: Result := 'Denegada';
    TStatusNota.Cancelada: Result := 'Cancelada';
    TStatusNota.Contingencia: Result := 'Contingência (pendente)';
  else
    Result := '';
  end;
end;

{ TRegimeTributarioHelper }

function TRegimeTributarioHelper.Codigo: Integer;
begin
  Result := Ord(Self) + 1;
end;

function TRegimeTributarioHelper.Descricao: string;
begin
  case Self of
    TRegimeTributario.SimplesNacional: Result := '1 - Simples Nacional';
    TRegimeTributario.SimplesExcesso: Result := '2 - Simples Nacional (excesso de sublimite)';
  else
    Result := '3 - Regime normal';
  end;
end;

function TRegimeTributarioHelper.EhSimples: Boolean;
begin
  Result := Self <> TRegimeTributario.RegimeNormal;
end;

class function TRegimeTributarioHelper.DeCodigo(ACodigo: Integer): TRegimeTributario;
begin
  if (ACodigo < 1) or (ACodigo > 3) then
    raise EValidacao.CreateFmt('CRT inválido: %d', [ACodigo]);
  Result := TRegimeTributario(ACodigo - 1);
end;

{ TIndicadorIEHelper }

function TIndicadorIEHelper.Codigo: Integer;
begin
  case Self of
    TIndicadorIE.Contribuinte: Result := 1;
    TIndicadorIE.Isento: Result := 2;
  else
    Result := 9;
  end;
end;

function TIndicadorIEHelper.Descricao: string;
begin
  case Self of
    TIndicadorIE.Contribuinte: Result := '1 - Contribuinte ICMS';
    TIndicadorIE.Isento: Result := '2 - Contribuinte isento';
  else
    Result := '9 - Não contribuinte';
  end;
end;

class function TIndicadorIEHelper.DeCodigo(ACodigo: Integer): TIndicadorIE;
begin
  case ACodigo of
    1: Result := TIndicadorIE.Contribuinte;
    2: Result := TIndicadorIE.Isento;
  else
    Result := TIndicadorIE.NaoContribuinte;
  end;
end;

{ TTipoEventoFiscalHelper }

function TTipoEventoFiscalHelper.Descricao: string;
begin
  case Self of
    TTipoEventoFiscal.Emissao: Result := 'Emissão';
    TTipoEventoFiscal.Cancelamento: Result := 'Cancelamento';
    TTipoEventoFiscal.CartaCorrecao: Result := 'Carta de correção';
    TTipoEventoFiscal.Inutilizacao: Result := 'Inutilização';
  else
    Result := 'Contingência';
  end;
end;

{ TResultadoOperacao }

class function TResultadoOperacao.Ok(const AMensagem: string): TResultadoOperacao;
begin
  Result.Sucesso := True;
  Result.Mensagem := AMensagem;
end;

class function TResultadoOperacao.Falha(const AMensagem: string): TResultadoOperacao;
begin
  Result.Sucesso := False;
  Result.Mensagem := AMensagem;
end;

end.
