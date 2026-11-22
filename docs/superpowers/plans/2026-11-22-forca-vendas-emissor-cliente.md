# Força de Vendas — Emissor e cliente VCL (frente 2) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** O emissor avisa a API quando a NF-e de um pedido é autorizada ou cancelada (com pendência e reenvio se a API estiver fora), e o cliente VCL passa a mostrar e editar o que o app Força de Vendas grava (código de barras, origem, vendedor, NF-e, local e assinatura).

**Architecture:** No emissor, um serviço novo `Service.AvisoFaturamento` fala com a API pelo `Infra.ApiPedidos` já existente e é injetado no `TNotaService`, que o chama depois de gravar a autorização ou o cancelamento; falha vira pendência na própria nota (`NOTA.FATURAMENTO_PENDENTE`) e é reenviada ao abrir o sistema e a tela de pedidos da API. No cliente VCL, modelos e units `Api.*` ganham os campos novos, a camada HTTP passa a devolver também os bytes da resposta (para a assinatura PNG) e as telas ganham colunas e campos.

**Tech Stack:** Delphi 13 (BDS 37.0), VCL, DevExpress VCL 26.1.5, FireDAC + Firebird, `System.Net.HttpClient`, DUnitX.

**Spec:** `C:\Projetos\Portifolio\GitHub\delphi-horse-api\delphi-horse-api\docs\superpowers\specs\2026-11-22-forca-vendas-design.md` — seção "2. Emissor e cliente VCL" e decisão 9. A API (frente 1) já está na `main` da delphi-horse-api.

## Global Constraints

- Falha no aviso à API **nunca** desfaz nem bloqueia a operação fiscal; só registra log (decisão 9 do spec).
- Emissor: ambiente sempre homologação por padrão; nada de certificado, senha, CNPJ/IE reais ou XML autorizado no repositório.
- Migração nova `database/006_faturamento_pendente.sql`; nunca editar 001–005. Termina com `COMMIT;`, UTF-8, compatível com Firebird 3.0; atualizar a tabela de Migrações do README do emissor.
- SQL só nos `Repository.*`, sempre parametrizado. Views sem SQL e sem ACBr.
- Telas com DevExpress (`TcxTextEdit`, `TcxGridColumn`, `TcxButton`, `TcxImage`/`TdxSmartImage`, `TcxLabel`); VCL padrão só sem equivalente.
- Unit nova vai no `uses` do `.dpr` **e** no `.dproj` (app e testes).
- `.pas` com acento: UTF-8 com BOM, CRLF. `.dfm`: acentos como `#nnn`.
- Estilo misto do CLAUDE.local.md: Controllers/Repositories/Services simples no estilo dia a dia; comentários só onde agregam.
- Commits pequenos, em português, no imperativo. Sem push até o Kauê pedir.
- **Emissor num worktree**: o `EmissorNFe.dproj` da cópia principal tem uma alteração do Kauê não commitada (configuração Android da IDE + `Infra.Migracao` no `.dproj`). O trabalho do emissor roda em `.worktrees/forca-vendas` (branch `forca-vendas` a partir da `main`), sem tocar na cópia principal. Cliente VCL: branch `forca-vendas` na cópia principal (está limpa).
- Testes: emissor `bash scratchpad/build/testes_emissor.sh` (ajustar `P=` para o worktree); cliente `bash scratchpad/build/testes_cliente.sh`. Suítes atuais verdes antes de começar.

## Review Focus

1. **API fora do ar na hora da autorização** — a nota fica Autorizada, a mensagem ao usuário é a mesma de sempre e a pendência fica gravada. Teste: `Emitir_ApiForaNoAviso_NotaAutorizadaEPendente` (Task 4) e `NotaAutorizada_ApiFora_MarcaPendente` (Task 3).
2. **Reenvio com a API ainda fora** — para na primeira falha, sem esperar o timeout de cada nota pendente. Teste: `Reenviar_ApiFora_ParaNaPrimeira` (Task 3).
3. **API recusa o aviso (409: pedido cancelado na API; 404)** — tentar de novo não resolve: registra no log e tira a pendência, em vez de tentar para sempre. Teste: `Reenviar_ApiRecusa_LimpaESegue` (Task 3).
4. **Nota autorizada com aviso pendente e cancelada antes do reenvio** — o reenvio manda o DELETE, não o PATCH. Teste: `Reenviar_CanceladaPendente_RemoveFaturamento` (Task 3).
5. **Editar no cliente VCL um produto que tem código de barras** — salvar sem mexer no campo não pode apagar o código (a API grava o que vier; hoje o cliente não manda o campo e o PUT o limparia). Teste: `Produto_Atualizar_EnviaCodigoBarras` (Task 6).

---

## Parte A — Emissor (`delphi-emissor-nfe`, worktree `.worktrees/forca-vendas`)

### Task 1: Cliente HTTP da API com PATCH/DELETE e erros separados

**Files:**
- Modify: `src/Infra/Infra.ApiPedidos.pas`
- Modify: `tests/Test.ApiPedidos.pas`, `tests/Test.FaturamentoPedido.pas` (stubs no `TPedidoApiFake`)

**Interfaces:**
- Produces:
  - `EApiIndisponivel = class(EApiPedidos)` — sem conexão, timeout, 5xx, ou login recusado (credencial do `config.ini`): **vale tentar de novo depois**.
  - `EApiPedidoRecusado = class(EApiPedidos)` — a API respondeu 400, 404, 409 ou 422: **tentar de novo não resolve**. Mensagem = campo `erro` do corpo.
  - `IPedidoApi.Faturar(APedidoId, ANumero, ASerie: Integer; const AChave: string; AAutorizadaEm: TDateTime)` → `PATCH /pedidos/:id/faturamento` com `{"numero","serie","chave","autorizadaEm"}`; `autorizadaEm` = `DateToISO8601(AAutorizadaEm, False)`.
  - `IPedidoApi.RemoverFaturamento(APedidoId: Integer)` → `DELETE /pedidos/:id/faturamento`.

- [ ] **Step 1: Testes que falham** em `Test.ApiPedidos.pas`:

```pascal
procedure TTestApiPedidos.Faturar_EnviaPatchComDadosDaNota;
// ResponderLogin; FTransporte.Responder(200, PEDIDO_12);
// FApi.Faturar(12, 123, 1, CHAVE_44, EncodeDateTime(2026, 11, 22, 14, 5, 0, 0));
// chamada[1]: Metodo = 'PATCH', Url = URL + '/pedidos/12/faturamento', Token = 'tk1'
// corpo: numero = 123, serie = 1, chave = CHAVE_44,
//        autorizadaEm = DateToISO8601(EncodeDateTime(2026,11,22,14,5,0,0), False)
procedure TTestApiPedidos.RemoverFaturamento_EnviaDelete;
// Metodo = 'DELETE', Url = URL + '/pedidos/12/faturamento'
procedure TTestApiPedidos.Faturar_401_RelogaERepete;
// login, 401, login, 200 → 4 chamadas, a última é PATCH com o token novo
procedure TTestApiPedidos.Faturar_409_LevantaRecusadoComMensagemDaApi;
// 409 '{"erro":"Pedido cancelado não pode ser faturado."}'
// Assert.WillRaiseWithMessage(..., EApiPedidoRecusado, 'Pedido cancelado não pode ser faturado.')
procedure TTestApiPedidos.Faturar_500_LevantaIndisponivel;   // EApiIndisponivel
procedure TTestApiPedidos.FalhaDeConexao_LevantaIndisponivel; // transporte levanta ENetHTTPClientException → EApiIndisponivel, mensagem com a URL
```

`CHAVE_44 = '35261111222333000181550010000001231000001230'`. Os testes atuais (`Erro404_UsaMensagemDaApi`, `FalhaDeConexao_MensagemComUrl`) continuam passando, porque as classes novas descendem de `EApiPedidos`.

- [ ] **Step 2: Rodar e ver falhar** — `bash testes_emissor.sh`. Expected: erro de compilação `Undeclared identifier: 'Faturar'` / `'EApiPedidoRecusado'`.

- [ ] **Step 3: Implementar.**
  - `TNetHttpTransporte.Executar`: tratar `PATCH` (`LCliente.Patch`) e `DELETE` (`LCliente.Delete`); atualizar o comentário "só GET e POST".
  - Generalizar `Get` para `Enviar(const AMetodo, ARota, ACorpo: string): string` com o mesmo relogin único no 401; `Get` vira uma chamada a `Enviar('GET', ...)` ou some.
  - `Chamar`: `ENetException` → `EApiIndisponivel`; status ≥ 500 → `EApiIndisponivel`; 400/404/409/422 → `EApiPedidoRecusado`; outros 4xx (menos 401) → `EApiPedidos`. Login com 401 → `EApiIndisponivel` com a mensagem atual sobre o `config.ini`.
  - `TPedidoApiFake` (Test.FaturamentoPedido): `Faturar` e `RemoverFaturamento` vazios.
  - Atualizar o comentário de cabeçalho da unit: agora o emissor também escreve na API (aviso de faturamento).

- [ ] **Step 4: Rodar** — Expected: suíte toda verde.

- [ ] **Step 5: Commit** — `git commit -m "Adiciona aviso de faturamento no cliente HTTP da API"`

---

### Task 2: Pendência de aviso na nota (migração + repositório)

**Files:**
- Create: `database/006_faturamento_pendente.sql`
- Modify: `src/Models/Model.Nota.pas`, `src/Repositories/Repository.Nota.pas`, `tests/Test.Fakes.pas`

**Interfaces:**
- Produces:
  - `TNota.FaturamentoPendente: Boolean` (lido em `LerCabecalho`).
  - `INotaRepository.MarcarFaturamentoPendente(ANotaId: Integer; APendente: Boolean)` — `UPDATE NOTA SET FATURAMENTO_PENDENTE = :P WHERE ID = :ID`.
  - `INotaRepository.ListarFaturamentoPendente: TObjectList<TNota>` — só cabeçalho, `WHERE FATURAMENTO_PENDENTE = 1 AND PEDIDO_API_ID IS NOT NULL ORDER BY ID`.
  - `TFakeNotaRepository` implementa os dois sobre as notas que já guarda (`MarcarFaturamentoPendente` altera `FaturamentoPendente` da nota guardada; `ListarFaturamentoPendente` devolve cópias das pendentes).

- [ ] **Step 1: Migração**

```sql
/*
  Aviso de faturamento à delphi-horse-api.
  FATURAMENTO_PENDENTE = 1: a nota foi autorizada ou cancelada mas a API não recebeu o aviso
  (estava fora do ar). O que reenviar sai da situação da nota: autorizada → PATCH, cancelada → DELETE.
*/
ALTER TABLE NOTA ADD FATURAMENTO_PENDENTE SMALLINT DEFAULT 0 NOT NULL;

COMMIT;
```

- [ ] **Step 2: Modelo, repositório real e fake** como nas Interfaces. `ListarFaturamentoPendente` usa `SQL_SELECT_NOTA`.

- [ ] **Step 3: Conferir no banco** — probe de console em `scratchpad/build/probe_fv2/` (fora do repositório) que roda `TMigracao` contra uma **cópia** do banco do emissor, depois `MarcarFaturamentoPendente(<id de uma nota com PEDIDO_API_ID>, True)` e `ListarFaturamentoPendente`. Sem nota com pedido na cópia: `UPDATE` direto pelo probe para criar uma. Expected: a migração 006 aplicada e gravada em `SCHEMA_VERSAO`, a nota volta na lista, e com `False` a lista fica vazia.

- [ ] **Step 4: Suíte** — `bash testes_emissor.sh`. Expected: verde (`Test.Migracao` continua passando com o arquivo novo).

- [ ] **Step 5: Commit** — `git commit -m "Adiciona pendência de aviso de faturamento na nota"`

---

### Task 3: Serviço de aviso de faturamento

**Files:**
- Create: `src/Services/Service.AvisoFaturamento.pas`
- Create: `tests/Test.AvisoFaturamento.pas`
- Modify: `EmissorNFe.dpr`, `EmissorNFe.dproj`, `tests/EmissorNFeTests.dpr`, `tests/EmissorNFeTests.dproj`

**Interfaces:**
- Consumes: Task 1 (`IPedidoApi.Faturar/RemoverFaturamento`, `EApiIndisponivel`, `EApiPedidoRecusado`); Task 2 (`MarcarFaturamentoPendente`, `ListarFaturamentoPendente`, `TNota.FaturamentoPendente`).
- Produces:

```pascal
IAvisoFaturamento = interface
  /// Nunca levanta exceção de API: sem API → pendência; recusa → log.
  procedure NotaAutorizada(ANota: TNota);
  procedure NotaCancelada(ANota: TNota);
  /// Reenvia as pendentes; para na primeira EApiIndisponivel. Devolve quantas foram aceitas.
  function ReenviarPendentes: Integer;
end;
TAvisoFaturamentoService.Create(AApi: IPedidoApi; ANotaRepo: INotaRepository; ALog: ILog)
```

Regras:
- `ANota.PedidoApiId = 0` → não faz nada.
- Autorizada → `Faturar(PedidoApiId, Numero, Serie, Chave, DataEmissao)`. A data de autorização é a `DataEmissao` (gravada no envio); a nota não guarda a hora do protocolo.
- Cancelada → `RemoverFaturamento(PedidoApiId)`.
- Sucesso: se `ANota.FaturamentoPendente`, chama `MarcarFaturamentoPendente(Id, False)`; `Log.Info('Pedido %d avisado na API: NF-e %d autorizada|cancelada')`.
- `EApiIndisponivel`: `MarcarFaturamentoPendente(Id, True)` + `Log.Erro` com a mensagem.
- `EApiPedidoRecusado` (e outra `EApiPedidos`): `Log.Erro('A API recusou o aviso do pedido %d: %s')` e tira a pendência, se havia.
- `ReenviarPendentes`: para cada nota da lista, Autorizada → aviso de autorizada; Cancelada → aviso de cancelada; outra situação → só tira a pendência. Numa `EApiIndisponivel`, para o laço (as restantes ficam pendentes).

- [ ] **Step 1: Testes que falham** (fake de `IPedidoApi` no próprio unit de teste, que grava as chamadas e pode levantar uma exceção configurada; `TFakeNotaRepository`; `TFakeLog`):

```pascal
NotaAutorizada_SemPedido_NaoChamaApi          // PedidoApiId = 0 → 0 chamadas
NotaAutorizada_ComPedido_EnviaDadosDaNota     // Faturar(12, 123, 1, CHAVE_44, DataEmissao)
NotaAutorizada_ApiFora_MarcaPendente          // fake levanta EApiIndisponivel → não levanta; nota guardada com FaturamentoPendente = True; log de erro
NotaAutorizada_ApiRecusa_SoRegistraLog        // EApiPedidoRecusado('Pedido cancelado não pode ser faturado.') → não pendente; log contém a mensagem
NotaCancelada_ComPedido_RemoveFaturamento     // RemoverFaturamento(12)
NotaCancelada_ComPendenciaAnterior_LimpaPendencia
Reenviar_AutorizadaPendente_FaturaELimpa      // devolve 1; lista de pendentes vazia
Reenviar_CanceladaPendente_RemoveFaturamento  // nota Cancelada pendente → DELETE, não PATCH
Reenviar_ApiFora_ParaNaPrimeira               // 2 pendentes; fake sempre indisponível → 1 chamada; devolve 0; as 2 continuam pendentes
Reenviar_ApiRecusa_LimpaESegue                // 2 pendentes; 1ª recusada, 2ª aceita → 2 chamadas; devolve 1; nenhuma pendente
```

- [ ] **Step 2: Rodar e ver falhar** — Expected: `File not found: 'Service.AvisoFaturamento.pas'` / identificador não declarado.
- [ ] **Step 3: Implementar** `Service.AvisoFaturamento.pas` e registrar nos `.dpr`/`.dproj`.
- [ ] **Step 4: Rodar** — Expected: suíte verde, `Tests Leaked : 0`.
- [ ] **Step 5: Commit** — `git commit -m "Adiciona serviço de aviso de faturamento à API"`

---

### Task 4: Aviso ligado à emissão, ao cancelamento e à abertura

**Files:**
- Modify: `src/Services/Service.Nota.pas`, `src/Controllers/Controller.Fabrica.pas`, `src/Controllers/Controller.PedidoApi.pas`, `src/Views/View.Principal.pas`, `src/Views/View.PedidoApi.pas`
- Modify: `tests/Test.NotaService.pas`

**Interfaces:**
- Consumes: Task 3 (`IAvisoFaturamento`, `TAvisoFaturamentoService`).
- Produces:
  - `TNotaService.Create(..., ALog: ILog; AAviso: IAvisoFaturamento = nil)` — `nil` = sem aviso (testes antigos não mudam).
  - `TFabrica.AvisoFaturamento: IAvisoFaturamento`; `TFabrica.NotaService` passa o aviso.
  - `TPedidoApiController.ReenviarAvisosPendentes` (class procedure): chama `ReenviarPendentes` e engole qualquer exceção com `Log.Erro` (é tarefa de fundo, nunca mensagem na tela).

- [ ] **Step 1: Testes que falham** em `Test.NotaService.pas` (fake de `IAvisoFaturamento` que grava as notas avisadas e pode levantar `Exception`):

```pascal
Emitir_NotaAutorizada_AvisaApi                  // emissor fake autoriza (cStat 100) → aviso.Autorizadas = [nota.Id]
Emitir_NotaRejeitada_NaoAvisa                   // cStat de rejeição → nenhuma chamada
Emitir_AvisoLevantaErro_NotaContinuaAutorizada  // aviso levanta Exception('banco fora') → Result.Sucesso = True, Status = Autorizada, log de erro
Cancelar_Homologado_AvisaCancelamento           // cStat 135 → aviso.Canceladas = [nota.Id]
Cancelar_NaoHomologado_NaoAvisa
```

`Emitir_ApiForaNoAviso_NotaAutorizadaEPendente`: integração com o serviço real da Task 3 (`TAvisoFaturamentoService` + fake de `IPedidoApi` indisponível + `TFakeNotaRepository`) → `Result.Sucesso = True`, mensagem igual à de uma autorização sem pedido (`'... autorizada.'`), nota guardada com `FaturamentoPendente = True`.

- [ ] **Step 2: Rodar e ver falhar** — Expected: compilação falha no parâmetro `AAviso`.
- [ ] **Step 3: Implementar.**
  - `TNotaService`: campo `FAviso`; método privado `procedure Avisar(ANota: TNota; ACancelada: Boolean)` com `try ... except on E: Exception do FLog.Erro(...)`, chamado em `ProcessarRetornoEmissao` depois de `AtualizarSituacao` quando a situação é `Autorizado`, e em `Cancelar` depois de `AtualizarSituacao` quando `LSucesso`. Sem `FAviso` → nada.
  - `TFabrica`: `AvisoFaturamento` monta `TAvisoFaturamentoService` com o mesmo `TPedidoApiHttp` de `FaturamentoPedidoService`; extrair a montagem do `TPedidoApiHttp` numa função privada para as duas usarem.
  - `View.Principal.FormShow` e a abertura de `View.PedidoApi` (antes do primeiro `Carregar`) chamam `TPedidoApiController.ReenviarAvisosPendentes`. Sem pendência, é uma consulta e nenhuma chamada HTTP.
- [ ] **Step 4: Rodar** — Expected: suíte verde; app (`EmissorNFe.dpr`) compila sem warning.
- [ ] **Step 5: Commit** — `git commit -m "Avisa a API ao autorizar ou cancelar a NF-e de um pedido"`

---

### Task 5: Emissor — prova contra a API real e documentação

**Files:**
- Modify: `README.md`, `config.example.ini` (comentário da seção `[Api]`)
- Create (fora do repo): `scratchpad/build/probe_aviso/` (console)

- [ ] **Step 1: Prova ponta a ponta** — subir a API (`DelphiHorseApi.exe`), criar um pedido pela API (Python, como o `e2e_forca_vendas.py`), e rodar o probe com o `TPedidoApiHttp` e o `TAvisoFaturamentoService` reais, sobre um `TFakeNotaRepository`:
  1. aviso de autorizada para o pedido → `GET /pedidos/:id` mostra `nota.numero`;
  2. aviso de cancelada → `nota` volta `null`;
  3. API parada → a nota fica pendente; API de volta → `ReenviarPendentes` = 1;
  4. pedido cancelado na API → aviso de autorizada vira log de recusa, sem pendência.
  Expected: os 4 casos como descrito. Limpar: cancelar o pedido de teste pela API (devolve o estoque).
- [ ] **Step 2: README** — seção "Integração com a delphi-horse-api" ganha o aviso de faturamento (quando dispara, pendência, reenvio ao abrir o sistema e a tela de pedidos, falha nunca bloqueia a nota); linha da `006_faturamento_pendente.sql` na tabela de Migrações; item no roadmap.
- [ ] **Step 3: Suíte** — Expected: verde.
- [ ] **Step 4: Commit** — `git commit -m "Documenta o aviso de faturamento à API"`

---

## Parte B — Cliente VCL (`delphi-vcl-client`, branch `forca-vendas`)

### Task 6: Código de barras no produto

**Files:**
- Modify: `src/Models/Model.Produto.pas`, `src/Api/Api.Produto.pas`, `src/Views/View.ProdutoEdicao.pas`, `src/Views/View.ProdutoEdicao.dfm`
- Modify: `tests/Test.ClienteProduto.pas`

**Interfaces:**
- Produces: `TProduto.CodigoBarras: string`; o JSON de `Criar`/`Atualizar` leva `"codigoBarras"` (vazio = sem código); a leitura preenche o campo.

- [ ] **Step 1: Testes que falham:**

```pascal
Produto_Obter_LeCodigoBarras          // '{"id":1,...,"codigoBarras":"7891000000014"}' → CodigoBarras = '7891000000014'
Produto_Atualizar_EnviaCodigoBarras   // corpo do PUT tem codigoBarras = '7891000000014'
Produto_Criar_SemCodigo_EnviaVazio    // corpo tem codigoBarras = ''
```

- [ ] **Step 2: Ver falhar** — Expected: `Undeclared identifier: 'CodigoBarras'`.
- [ ] **Step 3: Implementar** o modelo e a `Api.Produto` (com `Trim` no envio). Na tela: `lblCodigoBarras: TcxLabel` ("Código de barras") e `edtCodigoBarras: TcxTextEdit` (`Properties.MaxLength = 14`, largura 200) numa linha nova abaixo de Preço/Estoque, antes da dica de estoque; ajustar `TabOrder`, o `Height` do `pnlCartao` e o `ClientHeight` do form. A validação do dígito verificador fica na API (422 com a mensagem, já mostrada pela tela).
- [ ] **Step 4: Rodar** — `bash testes_cliente.sh`. Expected: verde, sem warning nem hint.
- [ ] **Step 5: Commit** — `git commit -m "Adiciona código de barras no cadastro de produto"`

---

### Task 7: Origem, vendedor e NF-e na lista de pedidos

**Files:**
- Modify: `src/Models/Model.Pedido.pas`, `src/Api/Api.Pedido.pas`, `src/Views/View.Pedidos.pas`
- Modify: `tests/Test.Pedido.pas`

**Interfaces:**
- Produces, em `TPedido`: `Origem: string` (`'API'`/`'APP'`, como vem da API), `VendedorNome: string`, `NotaNumero, NotaSerie: Integer` (0 = sem nota), `NotaChave: string`, `NotaAutorizadaEm: TDateTime`, `Observacao: string`, `TemAssinatura: Boolean`, `TemLocalizacao: Boolean`, `Latitude, Longitude, Precisao: Double`; e `function OrigemDescricao: string` (`'App'` para APP, senão `'API'`) e `function NotaDescricao: string` (`''` ou `'123/1'`).

- [ ] **Step 1: Testes que falham:**

```pascal
Listar_ConverteCamposDoApp
// pedido com origem "APP", vendedor {"id":2,"nome":"Ana Vendedora"},
// nota {"numero":123,"serie":1,"chave":CHAVE_44,"autorizadaEm":"2026-11-22T14:05:00-03:00"},
// localizacao {"latitude":-23.5505,"longitude":-46.6333,"precisao":9}, temAssinatura true, observacao "Entregar pela manhã"
// → OrigemDescricao = 'App', VendedorNome = 'Ana Vendedora', NotaDescricao = '123/1',
//   TemLocalizacao, Latitude = -23.5505 (com tolerância), TemAssinatura, Observacao
Listar_PedidoSemCamposNovos_FicaVazio
// JSON antigo (sem origem, vendedor/nota/localizacao null ou ausentes)
// → OrigemDescricao = 'API', VendedorNome = '', NotaDescricao = '', not TemLocalizacao, not TemAssinatura
```

- [ ] **Step 2: Ver falhar.**
- [ ] **Step 3: Implementar** a leitura em `PedidoDeJson` (`null` e ausente tratados igual) e as colunas em `TfraPedidos.CriarColunas`: `colOrigem` ("Origem", 70), `colVendedor` ("Vendedor", 160) e `colNota` ("NF-e", 90), preenchidas em `ExibirPagina`. Reduzir `colCliente` se a grade passar da largura da tela principal.
- [ ] **Step 4: Rodar** — Expected: verde.
- [ ] **Step 5: Commit** — `git commit -m "Mostra origem, vendedor e NF-e na lista de pedidos"`

---

### Task 8: Assinatura, local e NF-e no detalhe do pedido

**Files:**
- Modify: `src/Infra/Infra.Http.pas`, `src/Api/Api.Base.pas`, `src/Api/Api.Pedido.pas`, `src/Models/Model.Pedido.pas`, `src/Controllers/Controller.Pedido.pas`, `src/Views/View.PedidoDetalhe.pas`, `src/Views/View.PedidoDetalhe.dfm`
- Modify: `tests/Test.Fakes.pas`, `tests/Test.Pedido.pas`

**Interfaces:**
- Produces:
  - `THttpResposta.Bytes: TBytes` (corpo cru) e `THttpResposta.TipoConteudo: string`. O adaptador lê os bytes uma vez e monta `Corpo` com `TEncoding.UTF8.GetString`. No log HTTP, corpo que não é JSON nem texto vira `'<N bytes, image/png>'`.
  - `TApiBase.EnviarBinario(AMetodo: THttpMetodo; const ARota: string): TBytes` — mesmo relogin e tratamento de erro de `Enviar`.
  - `IPedidoApi.LerAssinatura(AId: Integer): TBytes` → `GET /pedidos/:id/assinatura`; 404 devolve vazio.
  - `function UrlMapa(ALatitude, ALongitude: Double): string` em `Model.Pedido` → `'https://www.openstreetmap.org/?mlat=%.6f&mlon=%.6f#map=17/%.6f/%.6f'` com `TFormatSettings.Invariant`.
  - `THttpFake.EnfileirarBytes(AStatus: Integer; const ABytes: TBytes; const ATipo: string)`.

- [ ] **Step 1: Testes que falham:**

```pascal
LerAssinatura_DevolveBytesDoPng        // EnfileirarBytes(200, PNG_8_BYTES, 'image/png') → mesmos bytes; GET em /pedidos/7/assinatura
LerAssinatura_404_DevolveVazio         // 404 '{"erro":"Pedido sem assinatura."}' → Length = 0, sem exceção
UrlMapa_UsaPontoDecimalComRegionalPtBr // FormatSettings.DecimalSeparator := ',' (restaurar no finally)
// UrlMapa(-23.5505, -46.6333) = 'https://www.openstreetmap.org/?mlat=-23.550500&mlon=-46.633300#map=17/-23.550500/-46.633300'
```

- [ ] **Step 2: Ver falhar.**
- [ ] **Step 3: Implementar** a camada HTTP e a API. Tela de detalhe, abaixo da grade de itens:
  - `lblNota: TcxLabel` — "Faturado na NF-e 123/1" ou "Ainda não faturado";
  - `lblVendedor`/`lblOrigem` junto de Cliente/Data;
  - `lblObservacao` (some se vazia);
  - `lblLocal` "Local: -23.550500, -46.633300 (±9 m)" + `btnMapa: TcxButton` "Ver no mapa" (`ShellExecute` com `UrlMapa`), ambos só com localização;
  - `imgAssinatura: TcxImage` (`Properties.GraphicClassName = 'TdxSmartImage'`, `Properties.Stretch`/proporcional, fundo branco), carregada em segundo plano pelo mesmo padrão assíncrono que a tela já usa para o pedido, só quando `TemAssinatura`. Falha ao carregar a imagem mostra "Assinatura indisponível" no lugar, sem diálogo de erro.

  Aumentar o form e o `pnlCartao`; em pedido sem dados do app, o form não pode ficar com buracos (esconder e reposicionar, ou reservar a área com "—").
- [ ] **Step 4: Rodar** — Expected: verde, sem warning/hint; app `DelphiVclClient.dpr` compila.
- [ ] **Step 5: Commit** — `git commit -m "Mostra assinatura, local e NF-e no detalhe do pedido"`

---

### Task 9: Cliente — prova com a API real, prints e documentação

**Files:**
- Modify: `README.md`
- Create: `docs/screenshots/produto-codigo-barras.png`, `docs/screenshots/pedidos-origem-nfe.png`, `docs/screenshots/pedido-detalhe-app.png`

- [ ] **Step 1: Dados** — API no ar; pelo Python: um pedido do app (com UUID, localização, assinatura PNG, como no `e2e_forca_vendas.py`) faturado via `PATCH /pedidos/:id/faturamento`.
- [ ] **Step 2: Prova na tela** — abrir o cliente, conferir: produto com código salvo e editado sem perder o código; lista com Origem "App", Vendedor e NF-e; detalhe com assinatura, local e "Ver no mapa" abrindo o OpenStreetMap. Capturar os três prints no mesmo processo dos prints anteriores do portfólio.
- [ ] **Step 3: README** — campos novos, link para o app Força de Vendas no ecossistema, prints, roadmap.
- [ ] **Step 4: Limpeza** — cancelar pelo sistema os pedidos de teste (remover o faturamento antes) e voltar o código do produto editado.
- [ ] **Step 5: Suíte** — Expected: verde.
- [ ] **Step 6: Commit** — `git commit -m "Documenta os campos do app Força de Vendas no cliente"`
