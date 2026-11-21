unit Infra.Documento;

{
  Validação e formatação de documentos: CPF, CNPJ, GTIN (EAN) e e-mail.
  Os dígitos verificadores seguem o cálculo módulo 11 da Receita Federal.
}

interface

function SoNumeros(const ATexto: string): string;

function CpfValido(const ACpf: string): Boolean;
function CnpjValido(const ACnpj: string): Boolean;

/// CPF (11 dígitos) ou CNPJ (14 dígitos), aceitando máscara.
function CpfCnpjValido(const ADocumento: string): Boolean;

function FormatarCpfCnpj(const ADocumento: string): string;

/// GTIN-8/12/13/14 com dígito verificador, ou o literal 'SEM GTIN'.
function GtinValido(const AGtin: string): Boolean;

/// Checagem simples de formato; o servidor de e-mail é quem valida de fato.
function EmailValido(const AEmail: string): Boolean;

implementation

uses
  System.SysUtils;

function SoNumeros(const ATexto: string): string;
var
  C: Char;
begin
  Result := '';
  for C in ATexto do
    if CharInSet(C, ['0'..'9']) then
      Result := Result + C;
end;

function TodosDigitosIguais(const ANumero: string): Boolean;
begin
  Result := ANumero = StringOfChar(ANumero[1], Length(ANumero));
end;

function DigitoModulo11(const ABase: string; APesoMaximo: Integer): Integer;
var
  I, LPeso, LSoma: Integer;
begin
  // percorre da direita para a esquerda com pesos 2..APesoMaximo
  LSoma := 0;
  LPeso := 2;
  for I := Length(ABase) downto 1 do
  begin
    Inc(LSoma, (Ord(ABase[I]) - Ord('0')) * LPeso);
    Inc(LPeso);
    if LPeso > APesoMaximo then
      LPeso := 2;
  end;
  Result := 11 - (LSoma mod 11);
  if Result >= 10 then
    Result := 0;
end;

function CpfValido(const ACpf: string): Boolean;
var
  LCpf: string;
  LDigito1, LDigito2: Integer;
begin
  LCpf := SoNumeros(ACpf);
  if (Length(LCpf) <> 11) or TodosDigitosIguais(LCpf) then
    Exit(False);

  // no CPF os pesos não reiniciam (vão de 2 até 10/11)
  LDigito1 := DigitoModulo11(Copy(LCpf, 1, 9), 10);
  LDigito2 := DigitoModulo11(Copy(LCpf, 1, 9) + IntToStr(LDigito1), 11);
  Result := (LCpf[10] = IntToStr(LDigito1)[1]) and (LCpf[11] = IntToStr(LDigito2)[1]);
end;

function CnpjValido(const ACnpj: string): Boolean;
var
  LCnpj: string;
  LDigito1, LDigito2: Integer;
begin
  LCnpj := SoNumeros(ACnpj);
  if (Length(LCnpj) <> 14) or TodosDigitosIguais(LCnpj) then
    Exit(False);

  // no CNPJ os pesos reiniciam em 2 depois do 9
  LDigito1 := DigitoModulo11(Copy(LCnpj, 1, 12), 9);
  LDigito2 := DigitoModulo11(Copy(LCnpj, 1, 12) + IntToStr(LDigito1), 9);
  Result := (LCnpj[13] = IntToStr(LDigito1)[1]) and (LCnpj[14] = IntToStr(LDigito2)[1]);
end;

function CpfCnpjValido(const ADocumento: string): Boolean;
var
  LNumeros: string;
begin
  LNumeros := SoNumeros(ADocumento);
  case Length(LNumeros) of
    11: Result := CpfValido(LNumeros);
    14: Result := CnpjValido(LNumeros);
  else
    Result := False;
  end;
end;

function FormatarCpfCnpj(const ADocumento: string): string;
var
  N: string;
begin
  N := SoNumeros(ADocumento);
  case Length(N) of
    11: Result := Format('%s.%s.%s-%s', [Copy(N, 1, 3), Copy(N, 4, 3), Copy(N, 7, 3), Copy(N, 10, 2)]);
    14: Result := Format('%s.%s.%s/%s-%s', [Copy(N, 1, 2), Copy(N, 3, 3), Copy(N, 6, 3), Copy(N, 9, 4), Copy(N, 13, 2)]);
  else
    Result := ADocumento;
  end;
end;

function GtinValido(const AGtin: string): Boolean;
var
  I, LSoma, LDigito: Integer;
  LGtin: string;
begin
  if SameText(Trim(AGtin), 'SEM GTIN') then
    Exit(True);

  LGtin := Trim(AGtin);
  if (LGtin <> SoNumeros(LGtin)) or not (Length(LGtin) in [8, 12, 13, 14]) then
    Exit(False);

  // pesos 3 e 1 alternados a partir do dígito à esquerda do verificador
  LSoma := 0;
  for I := Length(LGtin) - 1 downto 1 do
    if Odd(Length(LGtin) - I) then
      Inc(LSoma, (Ord(LGtin[I]) - Ord('0')) * 3)
    else
      Inc(LSoma, Ord(LGtin[I]) - Ord('0'));

  LDigito := (10 - (LSoma mod 10)) mod 10;
  Result := LDigito = Ord(LGtin[Length(LGtin)]) - Ord('0');
end;

function EmailValido(const AEmail: string): Boolean;
var
  LArroba, LPonto: Integer;
begin
  LArroba := Pos('@', AEmail);
  LPonto := AEmail.LastIndexOf('.') + 1;
  Result := (LArroba > 1) and (LPonto > LArroba + 1) and (LPonto < Length(AEmail))
    and (AEmail.CountChar('@') = 1) and (Pos(' ', AEmail) = 0);
end;

end.
