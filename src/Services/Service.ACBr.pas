unit Service.ACBr;

{
  Implementação de IEmissorFiscal com os componentes ACBr. É a ÚNICA unit do
  projeto que conhece o ACBr: montagem do XML, assinatura, validação de schema,
  transmissão, eventos, DANFE e e-mail.

  Os componentes são criados em código (e não num DataModule) para que esta
  unit seja autossuficiente e fácil de substituir por um fake nos testes.

  Requer o ACBr instalado pelo instalador oficial (pacotes ACBr_NFe,
  ACBr_NFeDanfeRL e ACBr_Mail no library path da IDE).
}

interface

uses
  System.SysUtils, System.Classes, ACBrNFe, ACBrNFeDANFeRLClass, ACBrDANFCeFortesFr,
  ACBrMail, Model.Tipos, Model.Nota, Model.Emitente, Model.Cliente, Service.EmissorFiscal;

type
  TEmissorACBr = class(TInterfacedObject, IEmissorFiscal)
  private
    FNFe: TACBrNFe;
    FDanfeNFe: TACBrNFeDANFeRL;
    FDanfeNFCe: TACBrNFeDANFCeFortes;
    FMail: TACBrMail;
    procedure Configurar(AModelo: TModeloNota; AContingencia: Boolean = False);
    procedure PrepararDanfe(AModelo: TModeloNota);
    procedure MontarNFe(ANota: TNota; AEmitente: TEmitente; ADestinatario: TCliente;
      AContingencia: Boolean);
    procedure CarregarXml(const AXml: string; AModelo: TModeloNota);
    function EnviarCarregada(ALote: Integer): TRetornoFiscal;
    function RetornoEvento: TRetornoFiscal;
  public
    constructor Create;
    destructor Destroy; override;

    function StatusServico(AModelo: TModeloNota): TRetornoFiscal;
    function Transmitir(ANota: TNota; AEmitente: TEmitente; ADestinatario: TCliente;
      AContingencia: Boolean): TRetornoFiscal;
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

function CriarEmissorACBr: IEmissorFiscal;

implementation

uses
  System.IOUtils, System.DateUtils, ACBrDFeSSL, ACBrDFeUtil, ACBrUtil.Base, ACBrDFe.Conversao, ACBrNFe.Conversao,
  Model.ItemNota, Model.Pagamento, Infra.Config, Infra.Documento;

const
  // textos exigidos pela SEFAZ em homologação (rejeições 598 e 373)
  NOME_DEST_HOMOLOGACAO = 'NF-E EMITIDA EM AMBIENTE DE HOMOLOGACAO - SEM VALOR FISCAL';
  PRODUTO_HOMOLOGACAO = 'NOTA FISCAL EMITIDA EM AMBIENTE DE HOMOLOGACAO - SEM VALOR FISCAL';
  JUSTIFICATIVA_CONTINGENCIA = 'Sem comunicacao com o webservice da SEFAZ';
  VERSAO_APLICATIVO = 'EmissorNFe 1.0';

function CriarEmissorACBr: IEmissorFiscal;
begin
  Result := TEmissorACBr.Create;
end;

{ TEmissorACBr }

constructor TEmissorACBr.Create;
begin
  inherited Create;
  FNFe := TACBrNFe.Create(nil);
  FDanfeNFe := TACBrNFeDANFeRL.Create(nil);
  FDanfeNFCe := TACBrNFeDANFCeFortes.Create(nil);
  FMail := TACBrMail.Create(nil);
end;

destructor TEmissorACBr.Destroy;
begin
  FNFe.DANFE := nil;
  FNFe.MAIL := nil;
  FMail.Free;
  FDanfeNFCe.Free;
  FDanfeNFe.Free;
  FNFe.Free;
  inherited;
end;

procedure TEmissorACBr.Configurar(AModelo: TModeloNota; AContingencia: Boolean);
var
  LCfg: TConfigNFe;
begin
  LCfg := Config.NFe;

  FNFe.Configuracoes.Geral.SSLLib := libWinCrypt;
  FNFe.Configuracoes.Geral.VersaoDF := ve400;
  if AModelo = TModeloNota.NFCe then
    FNFe.Configuracoes.Geral.ModeloDF := moNFCe
  else
    FNFe.Configuracoes.Geral.ModeloDF := moNFe;
  if AContingencia then
    FNFe.Configuracoes.Geral.FormaEmissao := teOffLine
  else
    FNFe.Configuracoes.Geral.FormaEmissao := teNormal;
  FNFe.Configuracoes.Geral.IdCSC := LCfg.IdCSC;
  FNFe.Configuracoes.Geral.CSC := LCfg.CSC;
  // os XMLs são gravados pela aplicação (IArquivoXml), não pelo ACBr
  FNFe.Configuracoes.Geral.Salvar := False;
  FNFe.Configuracoes.Arquivos.Salvar := False;
  FNFe.Configuracoes.Arquivos.PathSchemas := LCfg.PastaSchemas;

  FNFe.Configuracoes.Certificados.ArquivoPFX := LCfg.Certificado;
  FNFe.Configuracoes.Certificados.Senha := AnsiString(LCfg.SenhaCertificado);

  FNFe.Configuracoes.WebServices.UF := LCfg.UF;
  // produção só se o config.ini disser explicitamente "producao"
  if LCfg.Ambiente = TAmbienteFiscal.Producao then
    FNFe.Configuracoes.WebServices.Ambiente := taProducao
  else
    FNFe.Configuracoes.WebServices.Ambiente := taHomologacao;
  FNFe.Configuracoes.WebServices.Visualizar := False;
  FNFe.Configuracoes.WebServices.Salvar := False;
  FNFe.Configuracoes.WebServices.TimeOut := 30000;
end;

procedure TEmissorACBr.PrepararDanfe(AModelo: TModeloNota);
begin
  if AModelo = TModeloNota.NFCe then
  begin
    FDanfeNFCe.ViaConsumidor := True;
    FDanfeNFCe.ImprimeItens := True;
    FNFe.DANFE := FDanfeNFCe;
  end
  else
  begin
    FDanfeNFe.TipoDANFE := tiRetrato;
    FNFe.DANFE := FDanfeNFe;
  end;
  FNFe.DANFE.MostraPreview := True;
  FNFe.DANFE.PathPDF := TPath.Combine(TPath.GetTempPath, 'EmissorNFe');
  ForceDirectories(FNFe.DANFE.PathPDF);
end;

procedure TEmissorACBr.MontarNFe(ANota: TNota; AEmitente: TEmitente; ADestinatario: TCliente;
  AContingencia: Boolean);
var
  LHomologacao, LOk: Boolean;
  LItem: TItemNota;
  LPagamento: TPagamentoNota;
begin
  LHomologacao := Config.NFe.Ambiente = TAmbienteFiscal.Homologacao;
  FNFe.NotasFiscais.Clear;
  var LNFe := FNFe.NotasFiscais.Add.NFe;

  // identificação
  LNFe.Ide.cUF := UFparaCodigoUF(AEmitente.Endereco.UF);
  LNFe.Ide.cNF := GerarCodigoDFe(ANota.Numero);
  LNFe.Ide.natOp := ANota.NaturezaOperacao;
  LNFe.Ide.modelo := ANota.Modelo.Codigo;
  LNFe.Ide.serie := ANota.Serie;
  LNFe.Ide.nNF := ANota.Numero;
  LNFe.Ide.dEmi := ANota.DataEmissao;
  LNFe.Ide.tpNF := tnSaida;
  LNFe.Ide.cMunFG := AEmitente.Endereco.CodigoMunicipio;
  LNFe.Ide.finNFe := fnNormal;
  LNFe.Ide.indPres := pcPresencial;
  LNFe.Ide.indIntermed := iiSemOperacao;
  LNFe.Ide.procEmi := peAplicativoContribuinte;
  LNFe.Ide.verProc := VERSAO_APLICATIVO;
  if LHomologacao then
    LNFe.Ide.tpAmb := taHomologacao
  else
    LNFe.Ide.tpAmb := taProducao;

  if ANota.Modelo = TModeloNota.NFCe then
  begin
    LNFe.Ide.tpImp := tiNFCe;
    LNFe.Ide.idDest := doInterna;
    LNFe.Ide.indFinal := cfConsumidorFinal;
  end
  else
  begin
    LNFe.Ide.tpImp := tiRetrato;
    LNFe.Ide.dSaiEnt := ANota.DataEmissao;
    if (ADestinatario <> nil) and not SameText(ADestinatario.Endereco.UF, AEmitente.Endereco.UF) then
      LNFe.Ide.idDest := doInterestadual
    else
      LNFe.Ide.idDest := doInterna;
    if (ADestinatario <> nil) and (ADestinatario.IndicadorIE = TIndicadorIE.NaoContribuinte) then
      LNFe.Ide.indFinal := cfConsumidorFinal
    else
      LNFe.Ide.indFinal := cfNao;
  end;

  if AContingencia then
  begin
    LNFe.Ide.tpEmis := teOffLine;
    LNFe.Ide.dhCont := Now;
    LNFe.Ide.xJust := JUSTIFICATIVA_CONTINGENCIA;
  end
  else
    LNFe.Ide.tpEmis := teNormal;

  // emitente
  LNFe.Emit.CNPJCPF := AEmitente.CNPJ;
  LNFe.Emit.IE := AEmitente.IE;
  LNFe.Emit.xNome := AEmitente.RazaoSocial;
  LNFe.Emit.xFant := AEmitente.NomeFantasia;
  LNFe.Emit.EnderEmit.xLgr := AEmitente.Endereco.Logradouro;
  LNFe.Emit.EnderEmit.nro := AEmitente.Endereco.Numero;
  LNFe.Emit.EnderEmit.xCpl := AEmitente.Endereco.Complemento;
  LNFe.Emit.EnderEmit.xBairro := AEmitente.Endereco.Bairro;
  LNFe.Emit.EnderEmit.cMun := AEmitente.Endereco.CodigoMunicipio;
  LNFe.Emit.EnderEmit.xMun := AEmitente.Endereco.Municipio;
  LNFe.Emit.EnderEmit.UF := AEmitente.Endereco.UF;
  LNFe.Emit.EnderEmit.CEP := StrToIntDef(AEmitente.Endereco.CEP, 0);
  LNFe.Emit.EnderEmit.cPais := 1058;
  LNFe.Emit.EnderEmit.xPais := 'BRASIL';
  LNFe.Emit.EnderEmit.fone := AEmitente.Telefone;
  case AEmitente.Regime of
    TRegimeTributario.SimplesNacional: LNFe.Emit.CRT := crtSimplesNacional;
    TRegimeTributario.SimplesExcesso: LNFe.Emit.CRT := crtSimplesExcessoReceita;
  else
    LNFe.Emit.CRT := crtRegimeNormal;
  end;

  // destinatário
  if ADestinatario <> nil then
  begin
    LNFe.Dest.CNPJCPF := ADestinatario.CpfCnpj;
    if LHomologacao and (ANota.Modelo = TModeloNota.NFe) then
      LNFe.Dest.xNome := NOME_DEST_HOMOLOGACAO
    else
      LNFe.Dest.xNome := ADestinatario.Nome;
    case ADestinatario.IndicadorIE of
      TIndicadorIE.Contribuinte:
        begin
          LNFe.Dest.indIEDest := inContribuinte;
          LNFe.Dest.IE := ADestinatario.IE;
        end;
      TIndicadorIE.Isento: LNFe.Dest.indIEDest := inIsento;
    else
      LNFe.Dest.indIEDest := inNaoContribuinte;
    end;
    LNFe.Dest.Email := ADestinatario.Email;
    if ADestinatario.Endereco.Preenchido then
    begin
      LNFe.Dest.EnderDest.xLgr := ADestinatario.Endereco.Logradouro;
      LNFe.Dest.EnderDest.nro := ADestinatario.Endereco.Numero;
      LNFe.Dest.EnderDest.xCpl := ADestinatario.Endereco.Complemento;
      LNFe.Dest.EnderDest.xBairro := ADestinatario.Endereco.Bairro;
      LNFe.Dest.EnderDest.cMun := ADestinatario.Endereco.CodigoMunicipio;
      LNFe.Dest.EnderDest.xMun := ADestinatario.Endereco.Municipio;
      LNFe.Dest.EnderDest.UF := ADestinatario.Endereco.UF;
      LNFe.Dest.EnderDest.CEP := StrToIntDef(ADestinatario.Endereco.CEP, 0);
      LNFe.Dest.EnderDest.cPais := 1058;
      LNFe.Dest.EnderDest.xPais := 'BRASIL';
      LNFe.Dest.EnderDest.Fone := ADestinatario.Telefone;
    end;
  end
  else if ANota.CpfConsumidor <> '' then
  begin
    // NFC-e com CPF na nota, sem cadastro do cliente
    LNFe.Dest.CNPJCPF := SoNumeros(ANota.CpfConsumidor);
    LNFe.Dest.indIEDest := inNaoContribuinte;
  end;

  // itens
  for LItem in ANota.Itens do
  begin
    var LDet := LNFe.Det.New;
    LDet.Prod.nItem := LItem.NumeroItem;
    LDet.Prod.cProd := LItem.Codigo;
    LDet.Prod.cEAN := LItem.EAN;
    LDet.Prod.cEANTrib := LItem.EAN;
    if LHomologacao and (ANota.Modelo = TModeloNota.NFCe) and (LItem.NumeroItem = 1) then
      LDet.Prod.xProd := PRODUTO_HOMOLOGACAO
    else
      LDet.Prod.xProd := LItem.Descricao;
    LDet.Prod.NCM := LItem.NCM;
    LDet.Prod.CEST := LItem.CEST;
    LDet.Prod.CFOP := LItem.CFOP;
    LDet.Prod.uCom := LItem.Unidade;
    LDet.Prod.qCom := LItem.Quantidade;
    LDet.Prod.vUnCom := LItem.ValorUnitario;
    LDet.Prod.uTrib := LItem.Unidade;
    LDet.Prod.qTrib := LItem.Quantidade;
    LDet.Prod.vUnTrib := LItem.ValorUnitario;
    LDet.Prod.vProd := LItem.ValorProduto;
    LDet.Prod.vDesc := LItem.ValorDesconto;
    LDet.Prod.IndTot := itSomaTotalNFe;

    LDet.Imposto.ICMS.orig := TOrigemMercadoria(LItem.Origem);
    if Length(LItem.CstCsosn) = 3 then
      LDet.Imposto.ICMS.CSOSN := StrToCSOSNIcms(LItem.CstCsosn)
    else
    begin
      LDet.Imposto.ICMS.CST := StrToCSTICMS(LItem.CstCsosn);
      LDet.Imposto.ICMS.modBC := dbiValorOperacao;
      LDet.Imposto.ICMS.pRedBC := LItem.ReducaoBaseICMS;
      LDet.Imposto.ICMS.vBC := LItem.BaseICMS;
      LDet.Imposto.ICMS.pICMS := LItem.AliquotaICMS;
      LDet.Imposto.ICMS.vICMS := LItem.ValorICMS;
    end;

    LDet.Imposto.PIS.CST := StrToCSTPIS(LItem.CstPIS);
    LDet.Imposto.PIS.vBC := LItem.BasePIS;
    LDet.Imposto.PIS.pPIS := LItem.AliquotaPIS;
    LDet.Imposto.PIS.vPIS := LItem.ValorPIS;

    LDet.Imposto.COFINS.CST := StrToCSTCOFINS(LItem.CstCOFINS);
    LDet.Imposto.COFINS.vBC := LItem.BaseCOFINS;
    LDet.Imposto.COFINS.pCOFINS := LItem.AliquotaCOFINS;
    LDet.Imposto.COFINS.vCOFINS := LItem.ValorCOFINS;
  end;

  // totais
  LNFe.Total.ICMSTot.vBC := ANota.BaseICMS;
  LNFe.Total.ICMSTot.vICMS := ANota.ValorICMS;
  LNFe.Total.ICMSTot.vProd := ANota.ValorProdutos;
  LNFe.Total.ICMSTot.vDesc := ANota.ValorDesconto;
  LNFe.Total.ICMSTot.vPIS := ANota.ValorPIS;
  LNFe.Total.ICMSTot.vCOFINS := ANota.ValorCOFINS;
  LNFe.Total.ICMSTot.vNF := ANota.ValorTotal;

  LNFe.Transp.modFrete := mfSemFrete;

  // pagamentos
  for LPagamento in ANota.Pagamentos do
  begin
    var LPag := LNFe.pag.New;
    LPag.tPag := StrToFormaPagamento(LOk, LPagamento.CodigoSefaz);
    LPag.vPag := LPagamento.Valor;
    if (LPagamento.CodigoSefaz = '03') or (LPagamento.CodigoSefaz = '04') or
       (LPagamento.CodigoSefaz = '17') then
      LPag.tpIntegra := tiPagNaoIntegrado;
  end;
  LNFe.pag.vTroco := ANota.ValorTroco;

  LNFe.InfAdic.infCpl := ANota.Observacao;
end;

procedure TEmissorACBr.CarregarXml(const AXml: string; AModelo: TModeloNota);
begin
  Configurar(AModelo);
  FNFe.NotasFiscais.Clear;
  FNFe.NotasFiscais.LoadFromString(AXml);
end;

function TEmissorACBr.EnviarCarregada(ALote: Integer): TRetornoFiscal;
begin
  Result := Default(TRetornoFiscal);
  Result.DataHora := Now;
  Result.Chave := FNFe.NotasFiscais.Items[0].NumID;
  Result.XmlEnvio := FNFe.NotasFiscais.Items[0].XMLAssinado;

  try
    FNFe.Enviar(ALote, False, True);
  except
    on E: Exception do
    begin
      // sem cStat do lote = não houve resposta (internet, timeout, certificado na conexão TLS)
      if FNFe.WebServices.Enviar.cStat = 0 then
        Exit(TRetornoFiscal.Erro(E.Message, True));
      Result.CStat := FNFe.WebServices.Enviar.cStat;
      Result.Motivo := FNFe.WebServices.Enviar.xMotivo;
    end;
  end;

  if FNFe.NotasFiscais.Items[0].NFe.procNFe.cStat > 0 then
  begin
    Result.CStat := FNFe.NotasFiscais.Items[0].NFe.procNFe.cStat;
    Result.Motivo := FNFe.NotasFiscais.Items[0].NFe.procNFe.xMotivo;
    Result.Protocolo := FNFe.NotasFiscais.Items[0].NFe.procNFe.nProt;
  end
  else if Result.CStat = 0 then
  begin
    // rejeição no nível do lote (antes de processar a nota)
    Result.CStat := FNFe.WebServices.Enviar.cStat;
    Result.Motivo := FNFe.WebServices.Enviar.xMotivo;
  end;

  // autorizada ou denegada: o ACBr já devolve o nfeProc (NF-e + protocolo)
  if Result.Protocolo <> '' then
    Result.XmlRetorno := FNFe.NotasFiscais.Items[0].XMLOriginal;
end;

function TEmissorACBr.StatusServico(AModelo: TModeloNota): TRetornoFiscal;
begin
  Configurar(AModelo);
  try
    FNFe.WebServices.StatusServico.Executar;
    Result := Default(TRetornoFiscal);
    Result.CStat := FNFe.WebServices.StatusServico.cStat;
    Result.Motivo := FNFe.WebServices.StatusServico.xMotivo;
    Result.DataHora := Now;
  except
    on E: Exception do
      Result := TRetornoFiscal.Erro(E.Message, True);
  end;
end;

function TEmissorACBr.Transmitir(ANota: TNota; AEmitente: TEmitente; ADestinatario: TCliente;
  AContingencia: Boolean): TRetornoFiscal;
begin
  Configurar(ANota.Modelo, AContingencia);
  MontarNFe(ANota, AEmitente, ADestinatario, AContingencia);

  // assinatura e schema antes de qualquer envio
  try
    FNFe.NotasFiscais.Assinar;
    FNFe.NotasFiscais.Validar;
  except
    on E: Exception do
      Exit(TRetornoFiscal.Erro('Falha na validação do XML: ' + E.Message));
  end;

  if AContingencia then
  begin
    // offline: a nota vale com o XML assinado; a transmissão fica para depois
    Result := Default(TRetornoFiscal);
    Result.DataHora := Now;
    Result.Chave := FNFe.NotasFiscais.Items[0].NumID;
    Result.XmlEnvio := FNFe.NotasFiscais.Items[0].XMLAssinado;
    Result.Motivo := 'Gerada em contingência offline';
    Exit;
  end;

  Result := EnviarCarregada(ANota.Numero);
end;

function TEmissorACBr.TransmitirXml(const AXml: string; AModelo: TModeloNota): TRetornoFiscal;
begin
  CarregarXml(AXml, AModelo);
  Result := EnviarCarregada(FNFe.NotasFiscais.Items[0].NFe.Ide.nNF);
end;

function TEmissorACBr.RetornoEvento: TRetornoFiscal;
begin
  Result := Default(TRetornoFiscal);
  Result.DataHora := Now;
  if FNFe.WebServices.EnvEvento.EventoRetorno.retEvento.Count = 0 then
  begin
    Result.CStat := FNFe.WebServices.EnvEvento.cStat;
    Result.Motivo := FNFe.WebServices.EnvEvento.xMotivo;
    Exit;
  end;

  var LInfo := FNFe.WebServices.EnvEvento.EventoRetorno.retEvento.Items[0].RetInfEvento;
  Result.CStat := LInfo.cStat;
  Result.Motivo := LInfo.xMotivo;
  Result.Protocolo := LInfo.nProt;
  Result.Chave := LInfo.chNFe;
  Result.XmlRetorno := string(LInfo.XML);
end;

function TEmissorACBr.Cancelar(ANota: TNota; const ACnpjEmitente, AJustificativa: string): TRetornoFiscal;
begin
  Configurar(ANota.Modelo);
  FNFe.EventoNFe.Evento.Clear;
  var LEvento := FNFe.EventoNFe.Evento.New;
  LEvento.InfEvento.chNFe := ANota.Chave;
  LEvento.InfEvento.CNPJ := ACnpjEmitente;
  LEvento.InfEvento.dhEvento := Now;
  LEvento.InfEvento.tpEvento := teCancelamento;
  LEvento.InfEvento.detEvento.nProt := ANota.Protocolo;
  LEvento.InfEvento.detEvento.xJust := AJustificativa;

  try
    FNFe.EnviarEvento(1);
  except
    on E: Exception do
      if FNFe.WebServices.EnvEvento.cStat = 0 then
        Exit(TRetornoFiscal.Erro(E.Message, True));
  end;
  Result := RetornoEvento;
end;

function TEmissorACBr.CartaCorrecao(ANota: TNota; const ACnpjEmitente, ACorrecao: string;
  ASequencia: Integer): TRetornoFiscal;
begin
  Configurar(ANota.Modelo);
  FNFe.EventoNFe.Evento.Clear;
  var LEvento := FNFe.EventoNFe.Evento.New;
  LEvento.InfEvento.chNFe := ANota.Chave;
  LEvento.InfEvento.CNPJ := ACnpjEmitente;
  LEvento.InfEvento.dhEvento := Now;
  LEvento.InfEvento.tpEvento := teCCe;
  LEvento.InfEvento.nSeqEvento := ASequencia;
  LEvento.InfEvento.detEvento.xCorrecao := ACorrecao;

  try
    FNFe.EnviarEvento(ASequencia);
  except
    on E: Exception do
      if FNFe.WebServices.EnvEvento.cStat = 0 then
        Exit(TRetornoFiscal.Erro(E.Message, True));
  end;
  Result := RetornoEvento;
end;

function TEmissorACBr.Inutilizar(const ACnpjEmitente: string; AModelo: TModeloNota; ASerie, AAno,
  ANumeroInicial, ANumeroFinal: Integer; const AJustificativa: string): TRetornoFiscal;
begin
  Configurar(AModelo);
  Result := Default(TRetornoFiscal);
  Result.DataHora := Now;
  try
    // o modelo vem de Configuracoes.Geral.ModeloDF, já setado no Configurar
    FNFe.Inutilizar(ACnpjEmitente, AJustificativa, AAno, ASerie, ANumeroInicial, ANumeroFinal);
  except
    on E: Exception do
      if FNFe.WebServices.Inutilizacao.cStat = 0 then
        Exit(TRetornoFiscal.Erro(E.Message, True));
  end;
  Result.CStat := FNFe.WebServices.Inutilizacao.cStat;
  Result.Motivo := FNFe.WebServices.Inutilizacao.xMotivo;
  Result.Protocolo := FNFe.WebServices.Inutilizacao.Protocolo;
  Result.XmlRetorno := FNFe.WebServices.Inutilizacao.XML_ProcInutNFe;
end;

procedure TEmissorACBr.ImprimirDanfe(const AXml: string; AModelo: TModeloNota);
begin
  CarregarXml(AXml, AModelo);
  PrepararDanfe(AModelo);
  FNFe.NotasFiscais.Imprimir;
end;

function TEmissorACBr.GerarPdfDanfe(const AXml: string; AModelo: TModeloNota): string;
begin
  CarregarXml(AXml, AModelo);
  PrepararDanfe(AModelo);
  FNFe.NotasFiscais.ImprimirPDF;
  Result := FNFe.DANFE.ArquivoPDF;
end;

procedure TEmissorACBr.EnviarEmail(const AXml: string; AModelo: TModeloNota; const ADestinatario,
  AAssunto, AMensagem: string);
var
  LCfg: TConfigEmail;
  LMensagem: TStringList;
begin
  LCfg := Config.Email;
  if LCfg.Host = '' then
    raise EValidacao.Create('Configure o servidor de e-mail na seção [Email] do config.ini.');

  FMail.Host := LCfg.Host;
  FMail.Port := IntToStr(LCfg.Porta);
  FMail.Username := LCfg.Usuario;
  FMail.Password := LCfg.Senha;
  FMail.SetTLS := LCfg.TLS;
  FMail.From := LCfg.Remetente;
  FMail.FromName := LCfg.NomeRemetente;
  FNFe.MAIL := FMail;

  CarregarXml(AXml, AModelo);
  PrepararDanfe(AModelo);
  FNFe.DANFE.MostraPreview := False;

  LMensagem := TStringList.Create;
  try
    LMensagem.Text := AMensagem;
    FNFe.NotasFiscais.Items[0].EnviarEmail(ADestinatario, AAssunto, LMensagem, True);
  finally
    LMensagem.Free;
  end;
end;

end.
