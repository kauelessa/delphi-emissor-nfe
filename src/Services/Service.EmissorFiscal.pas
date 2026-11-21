unit Service.EmissorFiscal;

{
  Contrato da comunicação com a SEFAZ. A implementação real (Service.ACBr) é a
  única unit do projeto que conhece o ACBr; o resto da aplicação - e os testes,
  que usam um fake - dependem só desta interface.
}

interface

uses
  Model.Tipos, Model.Nota, Model.Emitente, Model.Cliente;

type
  TRetornoFiscal = record
    CStat: Integer;
    Motivo: string;
    Protocolo: string;
    Chave: string;
    /// XML assinado que foi (ou será, em contingência) enviado.
    XmlEnvio: string;
    /// XML de retorno: procNFe na autorização, procEventoNFe nos eventos,
    /// procInutNFe na inutilização.
    XmlRetorno: string;
    DataHora: TDateTime;
    /// True quando não houve resposta da SEFAZ (sem internet, timeout, DNS...).
    /// Diferente de rejeição: a nota pode ir para contingência.
    FalhaComunicacao: Boolean;
    class function Erro(const AMotivo: string; AFalhaComunicacao: Boolean = False): TRetornoFiscal; static;
  end;

  IEmissorFiscal = interface
    ['{1A2B3C4D-5E6F-4A7B-8C9D-0E1F2A3B4C5D}']
    function StatusServico(AModelo: TModeloNota): TRetornoFiscal;

    /// Monta, assina, valida o schema e transmite. Com AContingencia = True
    /// (NFC-e offline) só gera e assina com tpEmis = 9, sem transmitir.
    function Transmitir(ANota: TNota; AEmitente: TEmitente; ADestinatario: TCliente;
      AContingencia: Boolean): TRetornoFiscal;

    /// Envia à SEFAZ o XML de uma NFC-e emitida em contingência.
    function TransmitirXml(const AXml: string; AModelo: TModeloNota): TRetornoFiscal;

    function Cancelar(ANota: TNota; const ACnpjEmitente, AJustificativa: string): TRetornoFiscal;
    function CartaCorrecao(ANota: TNota; const ACnpjEmitente, ACorrecao: string;
      ASequencia: Integer): TRetornoFiscal;
    function Inutilizar(const ACnpjEmitente: string; AModelo: TModeloNota; ASerie, AAno,
      ANumeroInicial, ANumeroFinal: Integer; const AJustificativa: string): TRetornoFiscal;

    procedure ImprimirDanfe(const AXml: string; AModelo: TModeloNota);
    function GerarPdfDanfe(const AXml: string; AModelo: TModeloNota): string;
    procedure EnviarEmail(const AXml: string; AModelo: TModeloNota; const ADestinatario,
      AAssunto, AMensagem: string);
  end;

implementation

uses
  System.SysUtils;

class function TRetornoFiscal.Erro(const AMotivo: string; AFalhaComunicacao: Boolean): TRetornoFiscal;
begin
  Result := Default(TRetornoFiscal);
  Result.Motivo := AMotivo;
  Result.FalhaComunicacao := AFalhaComunicacao;
  Result.DataHora := Now;
end;

end.
