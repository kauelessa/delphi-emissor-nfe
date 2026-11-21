unit Service.Nota;

{
  Fluxo fiscal da NF-e/NFC-e: montagem da nota (itens, desconto, pagamentos),
  validação, numeração, transmissão, contingência offline da NFC-e e eventos
  (cancelamento, CC-e, inutilização).

  Regras que valem para toda operação fiscal:
  - o XML de envio e o de retorno são gravados em disco (IArquivoXml);
  - a operação é registrada no log e na tabela NOTA_EVENTO;
  - o retorno da SEFAZ é traduzido em mensagem clara (TRetornoSefaz).
}

interface

uses
  System.Generics.Collections, Model.Tipos, Model.Nota, Model.Emitente, Model.Cliente,
  Repository.Nota, Repository.Emitente, Repository.Cliente, Repository.Produto,
  Repository.FormaPagamento, Repository.EventoFiscal, Service.EmissorFiscal,
  Infra.ArquivoXml, Infra.Log;

type
  INotaService = interface
    ['{2B3C4D5E-6F7A-4B8C-9D0E-1F2A3B4C5D6E}']
    function NovaNota(AModelo: TModeloNota): TNota;
    function Obter(AId: Integer): TNota;
    function Listar(const AFiltro: TFiltroNota): TObjectList<TNota>;

    procedure AdicionarItem(ANota: TNota; AProdutoId: Integer; AQuantidade: Currency);
    procedure AdicionarItemPorCodigo(ANota: TNota; const ACodigo: string; AQuantidade: Currency);
    procedure RemoverItem(ANota: TNota; AIndice: Integer);
    procedure AplicarDesconto(ANota: TNota; AValor: Currency);
    procedure AdicionarPagamento(ANota: TNota; AFormaPagamentoId: Integer; AValor: Currency);
    procedure RemoverPagamento(ANota: TNota; AIndice: Integer);

    function Validar(ANota: TNota; AEmitente: TEmitente; ADestinatario: TCliente): TArray<string>;
    function Emitir(ANota: TNota): TResultadoOperacao;
    function TransmitirContingencia(ANotaId: Integer): TResultadoOperacao;
    function Cancelar(ANotaId: Integer; const AJustificativa: string): TResultadoOperacao;
    function CartaCorrecao(ANotaId: Integer; const ACorrecao: string): TResultadoOperacao;
    function Inutilizar(AModelo: TModeloNota; ASerie, ANumeroInicial, ANumeroFinal: Integer;
      const AJustificativa: string): TResultadoOperacao;
    function StatusServico(AModelo: TModeloNota): TResultadoOperacao;

    procedure Imprimir(ANotaId: Integer);
    function GerarPdf(ANotaId: Integer): string;
    function EnviarEmail(ANotaId: Integer; const ADestinatario: string): TResultadoOperacao;
    function ExportarXml(ANotaId: Integer; const APastaDestino: string): string;
  end;

  TNotaService = class(TInterfacedObject, INotaService)
  private
    FNotaRepo: INotaRepository;
    FEmitenteRepo: IEmitenteRepository;
    FClienteRepo: IClienteRepository;
    FProdutoRepo: IProdutoRepository;
    FFormaPagamentoRepo: IFormaPagamentoRepository;
    FEventoRepo: IEventoFiscalRepository;
    FEmissor: IEmissorFiscal;
    FArquivoXml: IArquivoXml;
    FLog: ILog;
    function ObterEmitente: TEmitente;
    function ObterNota(AId: Integer): TNota;
    function SalvarXml(const ACnpj, ANome, AConteudo: string): string;
    procedure RegistrarEvento(ATipo: TTipoEventoFiscal; ANota: TNota;
      const ARetorno: TRetornoFiscal; const ATexto, AArquivo: string; ASucesso: Boolean;
      ASequencia: Integer = 1);
    procedure RecalcularDesconto(ANota: TNota);
    function ProcessarRetornoEmissao(ANota: TNota; const ACnpj: string;
      const ARetorno: TRetornoFiscal): TResultadoOperacao;
    function EmitirContingencia(ANota: TNota; AEmitente: TEmitente;
      ADestinatario: TCliente): TResultadoOperacao;
    function ValidarJustificativa(const ATexto: string): string;
    function LerXmlAutorizado(ANota: TNota): string;
  public
    constructor Create(ANotaRepo: INotaRepository; AEmitenteRepo: IEmitenteRepository;
      AClienteRepo: IClienteRepository; AProdutoRepo: IProdutoRepository;
      AFormaPagamentoRepo: IFormaPagamentoRepository; AEventoRepo: IEventoFiscalRepository;
      AEmissor: IEmissorFiscal; AArquivoXml: IArquivoXml; ALog: ILog);

    function NovaNota(AModelo: TModeloNota): TNota;
    function Obter(AId: Integer): TNota;
    function Listar(const AFiltro: TFiltroNota): TObjectList<TNota>;

    procedure AdicionarItem(ANota: TNota; AProdutoId: Integer; AQuantidade: Currency);
    procedure AdicionarItemPorCodigo(ANota: TNota; const ACodigo: string; AQuantidade: Currency);
    procedure RemoverItem(ANota: TNota; AIndice: Integer);
    procedure AplicarDesconto(ANota: TNota; AValor: Currency);
    procedure AdicionarPagamento(ANota: TNota; AFormaPagamentoId: Integer; AValor: Currency);
    procedure RemoverPagamento(ANota: TNota; AIndice: Integer);

    function Validar(ANota: TNota; AEmitente: TEmitente; ADestinatario: TCliente): TArray<string>;
    function Emitir(ANota: TNota): TResultadoOperacao;
    function TransmitirContingencia(ANotaId: Integer): TResultadoOperacao;
    function Cancelar(ANotaId: Integer; const AJustificativa: string): TResultadoOperacao;
    function CartaCorrecao(ANotaId: Integer; const ACorrecao: string): TResultadoOperacao;
    function Inutilizar(AModelo: TModeloNota; ASerie, ANumeroInicial, ANumeroFinal: Integer;
      const AJustificativa: string): TResultadoOperacao;
    function StatusServico(AModelo: TModeloNota): TResultadoOperacao;

    procedure Imprimir(ANotaId: Integer);
    function GerarPdf(ANotaId: Integer): string;
    function EnviarEmail(ANotaId: Integer; const ADestinatario: string): TResultadoOperacao;
    function ExportarXml(ANotaId: Integer; const APastaDestino: string): string;
  end;

implementation

uses
  System.SysUtils, System.StrUtils, System.DateUtils, System.IOUtils, Model.ItemNota, Model.Pagamento,
  Model.Produto, Model.FormaPagamento, Model.EventoFiscal, Service.Calculo,
  Service.RetornoSefaz, Infra.Documento;

{ TNotaService }

constructor TNotaService.Create(ANotaRepo: INotaRepository; AEmitenteRepo: IEmitenteRepository;
  AClienteRepo: IClienteRepository; AProdutoRepo: IProdutoRepository;
  AFormaPagamentoRepo: IFormaPagamentoRepository; AEventoRepo: IEventoFiscalRepository;
  AEmissor: IEmissorFiscal; AArquivoXml: IArquivoXml; ALog: ILog);
begin
  inherited Create;
  FNotaRepo := ANotaRepo;
  FEmitenteRepo := AEmitenteRepo;
  FClienteRepo := AClienteRepo;
  FProdutoRepo := AProdutoRepo;
  FFormaPagamentoRepo := AFormaPagamentoRepo;
  FEventoRepo := AEventoRepo;
  FEmissor := AEmissor;
  FArquivoXml := AArquivoXml;
  FLog := ALog;
end;

{ --- auxiliares --- }

function TNotaService.ObterEmitente: TEmitente;
begin
  Result := FEmitenteRepo.Obter;
  if Result = nil then
    raise EValidacao.Create('Cadastre o emitente antes de emitir notas.');
end;

function TNotaService.ObterNota(AId: Integer): TNota;
begin
  Result := FNotaRepo.Obter(AId);
  if Result = nil then
    raise EValidacao.CreateFmt('Nota %d não encontrada.', [AId]);
end;

function TNotaService.SalvarXml(const ACnpj, ANome, AConteudo: string): string;
begin
  Result := '';
  if AConteudo = '' then
    Exit;
  try
    Result := FArquivoXml.Salvar(ACnpj, ANome, AConteudo, Now);
  except
    on E: Exception do
      // não perde a operação por causa do disco, mas deixa rastro no log
      FLog.Erro(Format('Falha ao gravar XML %s: %s', [ANome, E.Message]));
  end;
end;

procedure TNotaService.RegistrarEvento(ATipo: TTipoEventoFiscal; ANota: TNota;
  const ARetorno: TRetornoFiscal; const ATexto, AArquivo: string; ASucesso: Boolean;
  ASequencia: Integer);
var
  LEvento: TEventoFiscal;
begin
  LEvento := TEventoFiscal.Create(ATipo);
  try
    if ANota <> nil then
    begin
      LEvento.NotaId := ANota.Id;
      LEvento.Modelo := ANota.Modelo.Codigo;
      LEvento.Serie := ANota.Serie;
      LEvento.NumeroInicial := ANota.Numero;
      LEvento.NumeroFinal := ANota.Numero;
    end;
    LEvento.Sequencia := ASequencia;
    LEvento.CStat := ARetorno.CStat;
    LEvento.Motivo := ARetorno.Motivo;
    LEvento.Protocolo := ARetorno.Protocolo;
    LEvento.Texto := ATexto;
    LEvento.ArquivoXml := AArquivo;
    LEvento.Sucesso := ASucesso;
    FEventoRepo.Registrar(LEvento);
  finally
    LEvento.Free;
  end;
end;

function TNotaService.ValidarJustificativa(const ATexto: string): string;
begin
  Result := Trim(ATexto);
  if Length(Result) < JUSTIFICATIVA_MINIMO then
    raise EValidacao.CreateFmt('A justificativa precisa ter pelo menos %d caracteres.', [JUSTIFICATIVA_MINIMO]);
  if Length(Result) > JUSTIFICATIVA_MAXIMO then
    raise EValidacao.CreateFmt('A justificativa pode ter no máximo %d caracteres.', [JUSTIFICATIVA_MAXIMO]);
end;

function TNotaService.LerXmlAutorizado(ANota: TNota): string;
begin
  if not (ANota.Status in [TStatusNota.Autorizada, TStatusNota.Cancelada, TStatusNota.Contingencia]) then
    raise EValidacao.CreateFmt('Nota em situação "%s" não tem DANFE.', [ANota.Status.Descricao]);
  if ANota.ArquivoXml = '' then
    raise EValidacao.Create('XML da nota não localizado.');
  Result := FArquivoXml.Ler(ANota.ArquivoXml);
end;

{ --- montagem da nota --- }

function TNotaService.NovaNota(AModelo: TModeloNota): TNota;
begin
  Result := TNota.Create;
  Result.Modelo := AModelo;
end;

function TNotaService.Obter(AId: Integer): TNota;
begin
  Result := FNotaRepo.Obter(AId);
end;

function TNotaService.Listar(const AFiltro: TFiltroNota): TObjectList<TNota>;
begin
  Result := FNotaRepo.Listar(AFiltro);
end;

procedure TNotaService.RecalcularDesconto(ANota: TNota);
begin
  if ANota.Itens.Count = 0 then
    ANota.ValorDesconto := 0;
  TCalculoNota.RatearDesconto(ANota, ANota.ValorDesconto);
  TCalculoNota.CalcularTotais(ANota);
end;

procedure TNotaService.AdicionarItem(ANota: TNota; AProdutoId: Integer; AQuantidade: Currency);
var
  LProduto: TProduto;
  LItem: TItemNota;
begin
  if not ANota.Editavel then
    raise EValidacao.Create('Esta nota não pode mais ser alterada.');
  if AQuantidade <= 0 then
    raise EValidacao.Create('Informe uma quantidade maior que zero.');
  if ANota.Itens.Count >= MAXIMO_ITENS then
    raise EValidacao.CreateFmt('A nota pode ter no máximo %d itens.', [MAXIMO_ITENS]);

  LProduto := FProdutoRepo.Obter(AProdutoId);
  if LProduto = nil then
    raise EValidacao.Create('Produto não encontrado.');
  try
    if not LProduto.Ativo then
      raise EValidacao.Create('Produto inativo.');

    LItem := TItemNota.Create;
    LItem.CopiarProduto(LProduto);
    LItem.Quantidade := AQuantidade;
    ANota.Itens.Add(LItem);
  finally
    LProduto.Free;
  end;

  RecalcularDesconto(ANota);
end;

procedure TNotaService.AdicionarItemPorCodigo(ANota: TNota; const ACodigo: string;
  AQuantidade: Currency);
var
  LProduto: TProduto;
  LId: Integer;
begin
  LProduto := FProdutoRepo.ObterPorCodigo(ACodigo);
  if LProduto = nil then
    raise EValidacao.CreateFmt('Produto "%s" não encontrado.', [ACodigo]);
  LId := LProduto.Id;
  LProduto.Free;
  AdicionarItem(ANota, LId, AQuantidade);
end;

procedure TNotaService.RemoverItem(ANota: TNota; AIndice: Integer);
begin
  if not ANota.Editavel then
    raise EValidacao.Create('Esta nota não pode mais ser alterada.');
  if (AIndice < 0) or (AIndice >= ANota.Itens.Count) then
    raise EValidacao.Create('Item inválido.');
  ANota.Itens.Delete(AIndice);

  // sem itens suficientes para absorver o desconto, zera para não travar a tela
  if (ANota.Itens.Count > 0) and (ANota.ValorDesconto > 0) then
  begin
    ANota.ValorProdutos := 0;
    for var LItem in ANota.Itens do
      ANota.ValorProdutos := ANota.ValorProdutos +
        TCalculoNota.Arredondar(LItem.Quantidade * LItem.ValorUnitario);
    if ANota.ValorDesconto >= ANota.ValorProdutos then
      ANota.ValorDesconto := 0;
  end;
  RecalcularDesconto(ANota);
end;

procedure TNotaService.AplicarDesconto(ANota: TNota; AValor: Currency);
begin
  if not ANota.Editavel then
    raise EValidacao.Create('Esta nota não pode mais ser alterada.');
  TCalculoNota.RatearDesconto(ANota, AValor);
  ANota.ValorDesconto := AValor;
  TCalculoNota.CalcularTotais(ANota);
end;

procedure TNotaService.AdicionarPagamento(ANota: TNota; AFormaPagamentoId: Integer;
  AValor: Currency);
var
  LForma: TFormaPagamento;
  LPagamento: TPagamentoNota;
begin
  if not ANota.Editavel then
    raise EValidacao.Create('Esta nota não pode mais ser alterada.');
  if AValor <= 0 then
    raise EValidacao.Create('Informe um valor de pagamento maior que zero.');

  LForma := FFormaPagamentoRepo.Obter(AFormaPagamentoId);
  if LForma = nil then
    raise EValidacao.Create('Forma de pagamento não encontrada.');
  try
    LPagamento := TPagamentoNota.Create;
    LPagamento.FormaPagamentoId := LForma.Id;
    LPagamento.CodigoSefaz := LForma.CodigoSefaz;
    LPagamento.Descricao := LForma.Descricao;
    LPagamento.Valor := AValor;
    ANota.Pagamentos.Add(LPagamento);
  finally
    LForma.Free;
  end;
  TCalculoNota.CalcularTotais(ANota);
end;

procedure TNotaService.RemoverPagamento(ANota: TNota; AIndice: Integer);
begin
  if not ANota.Editavel then
    raise EValidacao.Create('Esta nota não pode mais ser alterada.');
  if (AIndice < 0) or (AIndice >= ANota.Pagamentos.Count) then
    raise EValidacao.Create('Pagamento inválido.');
  ANota.Pagamentos.Delete(AIndice);
  TCalculoNota.CalcularTotais(ANota);
end;

{ --- validação --- }

function TNotaService.Validar(ANota: TNota; AEmitente: TEmitente;
  ADestinatario: TCliente): TArray<string>;
var
  LErros: TList<string>;
  LItem: TItemNota;
  LCfopEsperado: Char;
begin
  LErros := TList<string>.Create;
  try
    if not ANota.Editavel then
      LErros.Add(Format('Nota em situação "%s" não pode ser transmitida.', [ANota.Status.Descricao]));

    // emitente
    if not CnpjValido(AEmitente.CNPJ) then
      LErros.Add('CNPJ do emitente inválido.');
    if Trim(AEmitente.IE) = '' then
      LErros.Add('Inscrição estadual do emitente não informada.');
    if not AEmitente.Endereco.Preenchido then
      LErros.Add('Endereço do emitente incompleto (logradouro, município e UF).');

    // destinatário
    if (ANota.Modelo = TModeloNota.NFe) and (ADestinatario = nil) then
      LErros.Add('NF-e exige destinatário. Selecione o cliente.');
    if ADestinatario <> nil then
    begin
      if not CpfCnpjValido(ADestinatario.CpfCnpj) then
        LErros.Add('CPF/CNPJ do destinatário inválido.');
      if (ANota.Modelo = TModeloNota.NFe) and not ADestinatario.Endereco.Preenchido then
        LErros.Add('Endereço do destinatário incompleto (logradouro, município e UF).');
      if (ADestinatario.IndicadorIE = TIndicadorIE.Contribuinte) and (Trim(ADestinatario.IE) = '') then
        LErros.Add('Destinatário contribuinte de ICMS precisa ter a inscrição estadual.');
      if (ANota.Modelo = TModeloNota.NFCe) and (ADestinatario.IndicadorIE <> TIndicadorIE.NaoContribuinte) then
        LErros.Add('NFC-e só pode ser emitida para consumidor final não contribuinte.');
    end;
    if (ANota.CpfConsumidor <> '') and not CpfCnpjValido(ANota.CpfConsumidor) then
      LErros.Add('CPF/CNPJ do consumidor inválido.');

    // itens
    if ANota.Itens.Count = 0 then
      LErros.Add('A nota não tem itens.');

    // NFC-e é sempre operação interna; NF-e depende da UF do destinatário
    LCfopEsperado := '5';
    if (ANota.Modelo = TModeloNota.NFe) and (ADestinatario <> nil)
      and (ADestinatario.Endereco.UF <> '')
      and not SameText(ADestinatario.Endereco.UF, AEmitente.Endereco.UF) then
      LCfopEsperado := '6';

    for LItem in ANota.Itens do
    begin
      if Length(SoNumeros(LItem.NCM)) <> 8 then
        LErros.Add(Format('Item %d: NCM deve ter 8 dígitos.', [LItem.NumeroItem]));
      if (Length(LItem.CFOP) <> 4) or (LItem.CFOP[1] <> LCfopEsperado) then
        LErros.Add(Format('Item %d: CFOP %s inválido para esta operação (esperado %sxxx).',
          [LItem.NumeroItem, LItem.CFOP, LCfopEsperado]));
      if AEmitente.Regime.EhSimples and (Length(LItem.CstCsosn) <> 3) then
        LErros.Add(Format('Item %d: emitente do Simples Nacional deve usar CSOSN (3 dígitos).', [LItem.NumeroItem]));
      if not AEmitente.Regime.EhSimples and (Length(LItem.CstCsosn) <> 2) then
        LErros.Add(Format('Item %d: emitente do regime normal deve usar CST (2 dígitos).', [LItem.NumeroItem]));
      if not GtinValido(LItem.EAN) then
        LErros.Add(Format('Item %d: GTIN/EAN inválido.', [LItem.NumeroItem]));
      if LItem.ValorUnitario <= 0 then
        LErros.Add(Format('Item %d: valor unitário deve ser maior que zero.', [LItem.NumeroItem]));
    end;

    // pagamentos
    if ANota.Pagamentos.Count = 0 then
      LErros.Add('Informe a forma de pagamento.')
    else if ANota.TotalPago < ANota.ValorTotal then
      LErros.Add(Format('Pagamentos (%s) não cobrem o total da nota (%s).',
        [FormatCurr('#,##0.00', ANota.TotalPago), FormatCurr('#,##0.00', ANota.ValorTotal)]));

    Result := LErros.ToArray;
  finally
    LErros.Free;
  end;
end;

{ --- emissão --- }

function TNotaService.Emitir(ANota: TNota): TResultadoOperacao;
var
  LEmitente: TEmitente;
  LDestinatario: TCliente;
  LErros: TArray<string>;
  LRetorno: TRetornoFiscal;
begin
  LEmitente := ObterEmitente;
  LDestinatario := nil;
  try
    if ANota.ClienteId > 0 then
      LDestinatario := FClienteRepo.Obter(ANota.ClienteId);

    TCalculoNota.CalcularTotais(ANota);
    LErros := Validar(ANota, LEmitente, LDestinatario);
    if Length(LErros) > 0 then
      Exit(TResultadoOperacao.Falha('Corrija antes de emitir:' + sLineBreak + sLineBreak +
        '- ' + string.Join(sLineBreak + '- ', LErros)));

    // a numeração só é consumida na primeira transmissão; rejeitada reenvia com o mesmo número
    if ANota.Numero = 0 then
    begin
      ANota.Serie := LEmitente.Serie(ANota.Modelo);
      ANota.Numero := FEmitenteRepo.ReservarNumero(ANota.Modelo);
    end;
    ANota.DataEmissao := Now;
    FNotaRepo.Salvar(ANota);

    FLog.Fiscal(Format('Transmitindo %s nº %d série %d (nota %d), total %s',
      [ANota.Modelo.Descricao, ANota.Numero, ANota.Serie, ANota.Id,
       FormatCurr('#,##0.00', ANota.ValorTotal)]));

    try
      LRetorno := FEmissor.Transmitir(ANota, LEmitente, LDestinatario, False);
    except
      on E: Exception do
        LRetorno := TRetornoFiscal.Erro('Erro ao transmitir: ' + E.Message);
    end;

    if LRetorno.FalhaComunicacao and (ANota.Modelo = TModeloNota.NFCe) then
    begin
      FLog.Fiscal(Format('Sem resposta da SEFAZ (%s). Entrando em contingência offline.', [LRetorno.Motivo]));
      Exit(EmitirContingencia(ANota, LEmitente, LDestinatario));
    end;

    Result := ProcessarRetornoEmissao(ANota, LEmitente.CNPJ, LRetorno);
  finally
    LDestinatario.Free;
    LEmitente.Free;
  end;
end;

function TNotaService.ProcessarRetornoEmissao(ANota: TNota; const ACnpj: string;
  const ARetorno: TRetornoFiscal): TResultadoOperacao;
var
  LNomeBase, LArquivoEnvio, LArquivoRetorno: string;
  LSituacao: TSituacaoRetorno;
begin
  if ARetorno.Chave <> '' then
  begin
    ANota.Chave := ARetorno.Chave;
    LNomeBase := ARetorno.Chave;
  end
  else
    LNomeBase := Format('nota-%d', [ANota.Id]);

  LArquivoEnvio := SalvarXml(ACnpj, LNomeBase + '-env', ARetorno.XmlEnvio);
  LArquivoRetorno := SalvarXml(ACnpj, LNomeBase + '-nfe', ARetorno.XmlRetorno);

  ANota.CStat := ARetorno.CStat;
  ANota.Motivo := ARetorno.Motivo;
  LSituacao := TRetornoSefaz.Situacao(ARetorno.CStat);

  case LSituacao of
    TSituacaoRetorno.Autorizado:
      begin
        ANota.Status := TStatusNota.Autorizada;
        ANota.Protocolo := ARetorno.Protocolo;
        ANota.ArquivoXml := LArquivoRetorno;
        Result := TResultadoOperacao.Ok(Format('%s nº %d autorizada.' + sLineBreak +
          'Protocolo: %s', [ANota.Modelo.Descricao, ANota.Numero, ARetorno.Protocolo]));
      end;
    TSituacaoRetorno.Denegado:
      begin
        ANota.Status := TStatusNota.Denegada;
        ANota.Protocolo := ARetorno.Protocolo;
        ANota.ArquivoXml := LArquivoRetorno;
        Result := TResultadoOperacao.Falha(TRetornoSefaz.Mensagem(ARetorno.CStat, ARetorno.Motivo));
      end;
    TSituacaoRetorno.SemResposta, TSituacaoRetorno.EmProcessamento:
      begin
        // não houve julgamento da SEFAZ: a nota continua editável para novo envio
        if ARetorno.FalhaComunicacao then
          Result := TResultadoOperacao.Falha('Sem comunicação com a SEFAZ. Verifique a internet e tente novamente.' +
            sLineBreak + sLineBreak + ARetorno.Motivo)
        else
          Result := TResultadoOperacao.Falha(TRetornoSefaz.Mensagem(ARetorno.CStat, ARetorno.Motivo));
      end;
  else
    ANota.Status := TStatusNota.Rejeitada;
    Result := TResultadoOperacao.Falha('Nota rejeitada pela SEFAZ:' + sLineBreak +
      TRetornoSefaz.Mensagem(ARetorno.CStat, ARetorno.Motivo));
  end;

  FNotaRepo.AtualizarSituacao(ANota);
  RegistrarEvento(TTipoEventoFiscal.Emissao, ANota, ARetorno, '',
    IfThen(LArquivoRetorno <> '', LArquivoRetorno, LArquivoEnvio), Result.Sucesso);
  FLog.Fiscal(Format('Retorno %s nº %d: cStat %d - %s', [ANota.Modelo.Descricao, ANota.Numero,
    ARetorno.CStat, ARetorno.Motivo]));
end;

function TNotaService.EmitirContingencia(ANota: TNota; AEmitente: TEmitente;
  ADestinatario: TCliente): TResultadoOperacao;
var
  LRetorno: TRetornoFiscal;
begin
  try
    LRetorno := FEmissor.Transmitir(ANota, AEmitente, ADestinatario, True);
  except
    on E: Exception do
      LRetorno := TRetornoFiscal.Erro(E.Message);
  end;

  if LRetorno.XmlEnvio = '' then
  begin
    FLog.Erro('Falha ao gerar NFC-e em contingência: ' + LRetorno.Motivo);
    Exit(TResultadoOperacao.Falha('Sem comunicação com a SEFAZ e não foi possível gerar a ' +
      'NFC-e em contingência:' + sLineBreak + LRetorno.Motivo));
  end;

  ANota.Contingencia := True;
  ANota.Status := TStatusNota.Contingencia;
  ANota.Chave := LRetorno.Chave;
  ANota.CStat := 0;
  ANota.Motivo := 'Emitida em contingência offline';
  ANota.ArquivoXml := SalvarXml(AEmitente.CNPJ, LRetorno.Chave + '-nfe', LRetorno.XmlEnvio);
  FNotaRepo.AtualizarSituacao(ANota);

  RegistrarEvento(TTipoEventoFiscal.Contingencia, ANota, LRetorno, 'Sem comunicação com a SEFAZ',
    ANota.ArquivoXml, True);
  FLog.Fiscal(Format('NFC-e nº %d emitida em contingência offline. Chave %s', [ANota.Numero, ANota.Chave]));

  Result := TResultadoOperacao.Ok(Format('Sem comunicação com a SEFAZ.' + sLineBreak +
    'NFC-e nº %d emitida em CONTINGÊNCIA OFFLINE.' + sLineBreak + sLineBreak +
    'Transmita a nota em "Notas emitidas" assim que a conexão voltar (prazo de até 24 horas).',
    [ANota.Numero]));
end;

function TNotaService.TransmitirContingencia(ANotaId: Integer): TResultadoOperacao;
var
  LNota: TNota;
  LEmitente: TEmitente;
  LRetorno: TRetornoFiscal;
begin
  LNota := ObterNota(ANotaId);
  try
    if LNota.Status <> TStatusNota.Contingencia then
      raise EValidacao.Create('Só notas em contingência podem ser retransmitidas por aqui.');

    LEmitente := ObterEmitente;
    try
      FLog.Fiscal(Format('Transmitindo NFC-e nº %d emitida em contingência', [LNota.Numero]));
      try
        LRetorno := FEmissor.TransmitirXml(FArquivoXml.Ler(LNota.ArquivoXml), LNota.Modelo);
      except
        on E: Exception do
          LRetorno := TRetornoFiscal.Erro(E.Message);
      end;

      if LRetorno.FalhaComunicacao then
        Exit(TResultadoOperacao.Falha('Ainda sem comunicação com a SEFAZ. Tente novamente mais tarde.'));

      // se a SEFAZ rejeitar, ArquivoXml continua apontando para o XML offline
      Result := ProcessarRetornoEmissao(LNota, LEmitente.CNPJ, LRetorno);
      if not Result.Sucesso and (LNota.Status = TStatusNota.Rejeitada) then
        Result.Mensagem := Result.Mensagem + sLineBreak + sLineBreak +
          'Corrija o problema e inutilize ou reemita a numeração conforme orientação da SEFAZ.';
    finally
      LEmitente.Free;
    end;
  finally
    LNota.Free;
  end;
end;

{ --- eventos --- }

function TNotaService.Cancelar(ANotaId: Integer; const AJustificativa: string): TResultadoOperacao;
var
  LNota: TNota;
  LEmitente: TEmitente;
  LJustificativa, LArquivo: string;
  LRetorno: TRetornoFiscal;
  LSucesso: Boolean;
begin
  LJustificativa := ValidarJustificativa(AJustificativa);
  LNota := ObterNota(ANotaId);
  try
    if LNota.Status <> TStatusNota.Autorizada then
      raise EValidacao.CreateFmt('Só é possível cancelar nota autorizada (situação atual: %s).',
        [LNota.Status.Descricao]);

    LEmitente := ObterEmitente;
    try
      FLog.Fiscal(Format('Cancelando %s nº %d, chave %s', [LNota.Modelo.Descricao, LNota.Numero, LNota.Chave]));
      try
        LRetorno := FEmissor.Cancelar(LNota, LEmitente.CNPJ, LJustificativa);
      except
        on E: Exception do
          LRetorno := TRetornoFiscal.Erro(E.Message, True);
      end;

      LArquivo := SalvarXml(LEmitente.CNPJ, LNota.Chave + '-can', LRetorno.XmlRetorno);
      LSucesso := TRetornoSefaz.Situacao(LRetorno.CStat) = TSituacaoRetorno.EventoRegistrado;
      RegistrarEvento(TTipoEventoFiscal.Cancelamento, LNota, LRetorno, LJustificativa, LArquivo, LSucesso);
      FLog.Fiscal(Format('Cancelamento nº %d: cStat %d - %s', [LNota.Numero, LRetorno.CStat, LRetorno.Motivo]));

      if LSucesso then
      begin
        LNota.Status := TStatusNota.Cancelada;
        LNota.CStat := LRetorno.CStat;
        LNota.Motivo := LRetorno.Motivo;
        FNotaRepo.AtualizarSituacao(LNota);
        Result := TResultadoOperacao.Ok(Format('Cancelamento homologado. Protocolo: %s', [LRetorno.Protocolo]));
      end
      else
        Result := TResultadoOperacao.Falha('Cancelamento não homologado:' + sLineBreak +
          TRetornoSefaz.Mensagem(LRetorno.CStat, LRetorno.Motivo));
    finally
      LEmitente.Free;
    end;
  finally
    LNota.Free;
  end;
end;

function TNotaService.CartaCorrecao(ANotaId: Integer; const ACorrecao: string): TResultadoOperacao;
var
  LNota: TNota;
  LEmitente: TEmitente;
  LCorrecao, LArquivo: string;
  LSequencia: Integer;
  LRetorno: TRetornoFiscal;
  LSucesso: Boolean;
begin
  LCorrecao := Trim(ACorrecao);
  if Length(LCorrecao) < JUSTIFICATIVA_MINIMO then
    raise EValidacao.CreateFmt('O texto da correção precisa ter pelo menos %d caracteres.', [JUSTIFICATIVA_MINIMO]);
  if Length(LCorrecao) > CORRECAO_MAXIMO then
    raise EValidacao.CreateFmt('O texto da correção pode ter no máximo %d caracteres.', [CORRECAO_MAXIMO]);

  LNota := ObterNota(ANotaId);
  try
    if LNota.Modelo <> TModeloNota.NFe then
      raise EValidacao.Create('Carta de correção só existe para NF-e (modelo 55).');
    if LNota.Status <> TStatusNota.Autorizada then
      raise EValidacao.Create('Só é possível corrigir nota autorizada.');

    LSequencia := FEventoRepo.ProximaSequenciaCCe(LNota.Id);
    if LSequencia > MAXIMO_CCE then
      raise EValidacao.CreateFmt('Limite de %d cartas de correção atingido para esta nota.', [MAXIMO_CCE]);

    LEmitente := ObterEmitente;
    try
      FLog.Fiscal(Format('Enviando CC-e %d da NF-e nº %d', [LSequencia, LNota.Numero]));
      try
        LRetorno := FEmissor.CartaCorrecao(LNota, LEmitente.CNPJ, LCorrecao, LSequencia);
      except
        on E: Exception do
          LRetorno := TRetornoFiscal.Erro(E.Message, True);
      end;

      LArquivo := SalvarXml(LEmitente.CNPJ, Format('%s-cce%.2d', [LNota.Chave, LSequencia]), LRetorno.XmlRetorno);
      LSucesso := TRetornoSefaz.Situacao(LRetorno.CStat) = TSituacaoRetorno.EventoRegistrado;
      RegistrarEvento(TTipoEventoFiscal.CartaCorrecao, LNota, LRetorno, LCorrecao, LArquivo, LSucesso, LSequencia);
      FLog.Fiscal(Format('CC-e %d nº %d: cStat %d - %s', [LSequencia, LNota.Numero, LRetorno.CStat, LRetorno.Motivo]));

      if LSucesso then
        Result := TResultadoOperacao.Ok(Format('Carta de correção nº %d registrada. Protocolo: %s',
          [LSequencia, LRetorno.Protocolo]))
      else
        Result := TResultadoOperacao.Falha('Carta de correção não registrada:' + sLineBreak +
          TRetornoSefaz.Mensagem(LRetorno.CStat, LRetorno.Motivo));
    finally
      LEmitente.Free;
    end;
  finally
    LNota.Free;
  end;
end;

function TNotaService.Inutilizar(AModelo: TModeloNota; ASerie, ANumeroInicial, ANumeroFinal: Integer;
  const AJustificativa: string): TResultadoOperacao;
var
  LEmitente: TEmitente;
  LJustificativa, LArquivo: string;
  LRetorno: TRetornoFiscal;
  LEvento: TEventoFiscal;
  LSucesso: Boolean;
begin
  LJustificativa := ValidarJustificativa(AJustificativa);
  if ANumeroInicial < 1 then
    raise EValidacao.Create('Número inicial inválido.');
  if ANumeroFinal < ANumeroInicial then
    raise EValidacao.Create('O número final deve ser maior ou igual ao inicial.');

  LEmitente := ObterEmitente;
  try
    FLog.Fiscal(Format('Inutilizando %s série %d, números %d a %d',
      [AModelo.Descricao, ASerie, ANumeroInicial, ANumeroFinal]));
    try
      LRetorno := FEmissor.Inutilizar(LEmitente.CNPJ, AModelo, ASerie, YearOf(Date),
        ANumeroInicial, ANumeroFinal, LJustificativa);
    except
      on E: Exception do
        LRetorno := TRetornoFiscal.Erro(E.Message, True);
    end;

    LArquivo := SalvarXml(LEmitente.CNPJ, Format('inut-%d-%.3d-%.9d-%.9d',
      [AModelo.Codigo, ASerie, ANumeroInicial, ANumeroFinal]), LRetorno.XmlRetorno);
    LSucesso := TRetornoSefaz.Situacao(LRetorno.CStat) = TSituacaoRetorno.InutilizacaoHomologada;

    // inutilização não pertence a uma nota, então o evento é montado à mão
    LEvento := TEventoFiscal.Create(TTipoEventoFiscal.Inutilizacao);
    try
      LEvento.Modelo := AModelo.Codigo;
      LEvento.Serie := ASerie;
      LEvento.NumeroInicial := ANumeroInicial;
      LEvento.NumeroFinal := ANumeroFinal;
      LEvento.CStat := LRetorno.CStat;
      LEvento.Motivo := LRetorno.Motivo;
      LEvento.Protocolo := LRetorno.Protocolo;
      LEvento.Texto := LJustificativa;
      LEvento.ArquivoXml := LArquivo;
      LEvento.Sucesso := LSucesso;
      FEventoRepo.Registrar(LEvento);
    finally
      LEvento.Free;
    end;
    FLog.Fiscal(Format('Inutilização: cStat %d - %s', [LRetorno.CStat, LRetorno.Motivo]));

    if LSucesso then
      Result := TResultadoOperacao.Ok(Format('Inutilização homologada. Protocolo: %s', [LRetorno.Protocolo]))
    else
      Result := TResultadoOperacao.Falha('Inutilização não homologada:' + sLineBreak +
        TRetornoSefaz.Mensagem(LRetorno.CStat, LRetorno.Motivo));
  finally
    LEmitente.Free;
  end;
end;

function TNotaService.StatusServico(AModelo: TModeloNota): TResultadoOperacao;
var
  LRetorno: TRetornoFiscal;
begin
  try
    LRetorno := FEmissor.StatusServico(AModelo);
  except
    on E: Exception do
      LRetorno := TRetornoFiscal.Erro(E.Message, True);
  end;
  FLog.Info(Format('Status do serviço %s: cStat %d - %s', [AModelo.Descricao, LRetorno.CStat, LRetorno.Motivo]));

  if TRetornoSefaz.Situacao(LRetorno.CStat) = TSituacaoRetorno.ServicoEmOperacao then
    Result := TResultadoOperacao.Ok(TRetornoSefaz.Mensagem(LRetorno.CStat, LRetorno.Motivo))
  else
    Result := TResultadoOperacao.Falha(TRetornoSefaz.Mensagem(LRetorno.CStat, LRetorno.Motivo));
end;

{ --- impressão, e-mail e XML --- }

procedure TNotaService.Imprimir(ANotaId: Integer);
var
  LNota: TNota;
begin
  LNota := ObterNota(ANotaId);
  try
    FEmissor.ImprimirDanfe(LerXmlAutorizado(LNota), LNota.Modelo);
  finally
    LNota.Free;
  end;
end;

function TNotaService.GerarPdf(ANotaId: Integer): string;
var
  LNota: TNota;
begin
  LNota := ObterNota(ANotaId);
  try
    Result := FEmissor.GerarPdfDanfe(LerXmlAutorizado(LNota), LNota.Modelo);
  finally
    LNota.Free;
  end;
end;

function TNotaService.EnviarEmail(ANotaId: Integer; const ADestinatario: string): TResultadoOperacao;
var
  LNota: TNota;
  LEmitente: TEmitente;
  LAssunto: string;
begin
  if not EmailValido(Trim(ADestinatario)) then
    raise EValidacao.Create('Informe um e-mail válido.');

  LNota := ObterNota(ANotaId);
  try
    if LNota.Status <> TStatusNota.Autorizada then
      raise EValidacao.Create('Só notas autorizadas podem ser enviadas por e-mail.');

    LEmitente := ObterEmitente;
    try
      LAssunto := Format('%s nº %d - %s', [LNota.Modelo.Descricao, LNota.Numero, LEmitente.RazaoSocial]);
      try
        FEmissor.EnviarEmail(LerXmlAutorizado(LNota), LNota.Modelo, Trim(ADestinatario), LAssunto,
          Format('Segue em anexo o XML e o DANFE da %s nº %d.' + sLineBreak + 'Chave de acesso: %s',
            [LNota.Modelo.Descricao, LNota.Numero, LNota.Chave]));
        FLog.Info(Format('%s nº %d enviada para %s', [LNota.Modelo.Descricao, LNota.Numero, ADestinatario]));
        Result := TResultadoOperacao.Ok('E-mail enviado.');
      except
        on E: Exception do
        begin
          FLog.Erro(Format('Falha ao enviar e-mail da nota %d: %s', [LNota.Id, E.Message]));
          Result := TResultadoOperacao.Falha('Não foi possível enviar o e-mail:' + sLineBreak + E.Message);
        end;
      end;
    finally
      LEmitente.Free;
    end;
  finally
    LNota.Free;
  end;
end;

function TNotaService.ExportarXml(ANotaId: Integer; const APastaDestino: string): string;
var
  LNota: TNota;
begin
  LNota := ObterNota(ANotaId);
  try
    if (LNota.ArquivoXml = '') or not FileExists(LNota.ArquivoXml) then
      raise EValidacao.Create('XML da nota não localizado.');
    Result := TPath.Combine(APastaDestino, ExtractFileName(LNota.ArquivoXml));
    TFile.Copy(LNota.ArquivoXml, Result, True);
  finally
    LNota.Free;
  end;
end;

end.
