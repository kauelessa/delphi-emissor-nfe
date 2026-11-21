unit Service.RetornoSefaz;

{
  Interpretação do cStat devolvido pela SEFAZ. A ideia é que o usuário leia
  uma orientação do que fazer, não só o xMotivo cru do webservice.
  Referência: tabela de códigos do MOC da NF-e (Anexo I) e NT de rejeições.
}

interface

type
  TSituacaoRetorno = (Autorizado, Denegado, Duplicidade, EmProcessamento, Rejeitado,
    EventoRegistrado, InutilizacaoHomologada, ServicoEmOperacao, ServicoParalisado,
    SemResposta);

  TRetornoSefaz = class
  public
    class function Situacao(ACStat: Integer): TSituacaoRetorno; static;
    class function Autorizado(ACStat: Integer): Boolean; static;
    class function Denegado(ACStat: Integer): Boolean; static;
    /// Texto para o usuário: "cStat - xMotivo" + orientação quando conhecida.
    class function Mensagem(ACStat: Integer; const AMotivo: string): string; static;
  end;

implementation

uses
  System.SysUtils;

class function TRetornoSefaz.Situacao(ACStat: Integer): TSituacaoRetorno;
begin
  case ACStat of
    0: Result := TSituacaoRetorno.SemResposta;
    100, 150: Result := TSituacaoRetorno.Autorizado;
    102: Result := TSituacaoRetorno.InutilizacaoHomologada;
    103, 105: Result := TSituacaoRetorno.EmProcessamento;
    107: Result := TSituacaoRetorno.ServicoEmOperacao;
    108, 109: Result := TSituacaoRetorno.ServicoParalisado;
    110, 205, 301, 302, 303: Result := TSituacaoRetorno.Denegado;
    // 135 evento vinculado, 136 evento registrado sem vínculo, 155 cancelamento fora do prazo
    135, 136, 155: Result := TSituacaoRetorno.EventoRegistrado;
    204, 539: Result := TSituacaoRetorno.Duplicidade;
  else
    Result := TSituacaoRetorno.Rejeitado;
  end;
end;

class function TRetornoSefaz.Autorizado(ACStat: Integer): Boolean;
begin
  Result := Situacao(ACStat) = TSituacaoRetorno.Autorizado;
end;

class function TRetornoSefaz.Denegado(ACStat: Integer): Boolean;
begin
  Result := Situacao(ACStat) = TSituacaoRetorno.Denegado;
end;

function Orientacao(ACStat: Integer): string;
begin
  case ACStat of
    103, 105:
      Result := 'O lote ainda está em processamento na SEFAZ. Consulte a nota novamente em alguns instantes.';
    108, 109:
      Result := 'Serviço da SEFAZ indisponível. Para NFC-e, emita em contingência offline; para NF-e, tente mais tarde.';
    110, 301, 302, 303:
      Result := 'Uso denegado: há irregularidade fiscal do emitente ou destinatário. A numeração fica bloqueada e a nota não pode ser reutilizada.';
    204:
      Result := 'Já existe nota autorizada com este número. Consulte a situação pela chave antes de reenviar.';
    213:
      Result := 'O CNPJ do emitente difere do CNPJ do certificado digital. Confira o cadastro do emitente.';
    215, 225:
      Result := 'O XML não passou na validação de schema da SEFAZ. Confira os dados do emitente, destinatário e produtos.';
    280, 281, 282, 283, 284, 285, 286:
      Result := 'Problema com o certificado digital (vencido, revogado ou inválido). Verifique o certificado configurado.';
    233, 234:
      Result := 'Inscrição estadual do destinatário inválida. Confira a IE e o indicador de IE no cadastro do cliente.';
    207, 208, 209:
      Result := 'CNPJ/IE do emitente inválido ou não habilitado. Confira o cadastro do emitente.';
    232, 237:
      Result := 'CPF/CNPJ do destinatário inválido. Confira o cadastro do cliente.';
    539:
      Result := 'Duplicidade com diferença na chave de acesso. Consulte a nota pela chave original.';
    218, 420:
      Result := 'A nota já está cancelada na SEFAZ.';
    501:
      Result := 'Prazo de cancelamento expirado. Avalie emitir uma nota de entrada para estornar a operação.';
    563:
      Result := 'Já existe pedido de inutilização para esta faixa de numeração.';
    704:
      Result := 'NFC-e com data/hora de emissão atrasada. Confira o relógio do computador.';
    778:
      Result := 'NCM inexistente. Corrija o NCM no cadastro do produto.';
    656:
      Result := 'Consumo indevido: muitas requisições seguidas. Aguarde alguns minutos antes de tentar de novo.';
  else
    Result := '';
  end;
end;

class function TRetornoSefaz.Mensagem(ACStat: Integer; const AMotivo: string): string;
var
  LOrientacao: string;
begin
  if ACStat = 0 then
    Result := AMotivo
  else
    Result := Format('%d - %s', [ACStat, AMotivo]);

  LOrientacao := Orientacao(ACStat);
  if LOrientacao <> '' then
    Result := Result + sLineBreak + sLineBreak + LOrientacao;
end;

end.
