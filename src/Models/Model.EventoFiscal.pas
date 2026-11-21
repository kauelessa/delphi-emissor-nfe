unit Model.EventoFiscal;

interface

uses
  Model.Tipos;

type
  TEventoFiscal = class
  private
    FId: Integer;
    FNotaId: Integer;
    FTipo: TTipoEventoFiscal;
    FDataHora: TDateTime;
    FSequencia: Integer;
    FModelo: Integer;
    FSerie: Integer;
    FNumeroInicial: Integer;
    FNumeroFinal: Integer;
    FCStat: Integer;
    FMotivo: string;
    FProtocolo: string;
    FTexto: string;
    FArquivoXml: string;
    FSucesso: Boolean;
  public
    constructor Create(ATipo: TTipoEventoFiscal);
    property Id: Integer read FId write FId;
    property NotaId: Integer read FNotaId write FNotaId;
    property Tipo: TTipoEventoFiscal read FTipo write FTipo;
    property DataHora: TDateTime read FDataHora write FDataHora;
    property Sequencia: Integer read FSequencia write FSequencia;
    property Modelo: Integer read FModelo write FModelo;
    property Serie: Integer read FSerie write FSerie;
    property NumeroInicial: Integer read FNumeroInicial write FNumeroInicial;
    property NumeroFinal: Integer read FNumeroFinal write FNumeroFinal;
    property CStat: Integer read FCStat write FCStat;
    property Motivo: string read FMotivo write FMotivo;
    property Protocolo: string read FProtocolo write FProtocolo;
    // justificativa (cancelamento/inutilização) ou texto da correção (CC-e)
    property Texto: string read FTexto write FTexto;
    property ArquivoXml: string read FArquivoXml write FArquivoXml;
    property Sucesso: Boolean read FSucesso write FSucesso;
  end;

implementation

uses
  System.SysUtils;

constructor TEventoFiscal.Create(ATipo: TTipoEventoFiscal);
begin
  inherited Create;
  FTipo := ATipo;
  FDataHora := Now;
  FSequencia := 1;
end;

end.
