# Faturar pedido da API — plano de implementação

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Na tela de NF-e do emissor, importar um pedido da delphi-horse-api e chegar à nota preenchida (destinatário, itens com preço do pedido), pronta para informar o pagamento e emitir.

**Architecture:** Um cliente HTTP pequeno em `Infra` (`IPedidoApi`, sobre um transporte `IHttpTransporte` substituível nos testes) lê pedidos e clientes da API. `Service.FaturamentoPedido` valida o pedido, resolve o cliente pelo CPF/CNPJ e cada produto pelo vínculo gravado (`PRODUTO_VINCULO_API`), pedindo à tela por callbacks o que só o usuário decide, e preenche a nota via `INotaService`. Views novas: lista de pedidos e escolha de produto.

**Tech Stack:** Delphi 13 VCL Win32, DevExpress VCL 26.1.5, FireDAC + Firebird, `System.Net.HttpClient`, `System.JSON`, DUnitX.

**Spec:** `docs/superpowers/specs/2026-11-22-faturar-pedido-api-design.md`

## Global Constraints

- Camadas do CLAUDE.md: Views sem SQL/HTTP/ACBr; SQL só em `Repositories` e sempre parametrizado; HTTP só em `Infra.ApiPedidos`.
- Banco: script novo `database/005_pedido_api.sql`, termina com `COMMIT;`, UTF-8, compatível com Firebird 3.0; nunca alterar 001–004. Atualizar a tabela de migrações do `README.md`.
- Senha da API só no `config.ini`; `config.example.ini` com `Senha=` vazia. Ambiente fiscal continua `homologacao`.
- UI com DevExpress (`TcxGrid`, `TdxLayoutControl`, `TcxButton`, `TcxLookupComboBox`); `.dfm` pode ser gerado à mão (autorizado neste projeto), com acentos como `#nnn`. `.pas` com acento em UTF-8 com BOM.
- Units novas entram no `uses` de `EmissorNFe.dpr` (e de `tests/EmissorNFeTests.dpr` quando testadas); não editar `.dproj`/`.res` — avisar o Kauê para conferir pela IDE.
- Mensagens exatas: `'Pedido cancelado na API não pode ser faturado.'`, `'Pedido %d já faturado na NF-e %d.'`, `'Importe o pedido numa NF-e nova, sem itens.'`, `'Não foi possível conectar à API em %s.'`.
- Observação da nota: `'Pedido nº %d (delphi-horse-api)'`.
- Commits pequenos, em português, no imperativo; commit/push só quando o Kauê pedir no fim (como no projeto do cliente).
- Estilo do CLAUDE.local.md: Controllers/Repositories com cara de código do dia a dia; comentário só onde agrega.

## Review Focus

1. Vínculo gravado apontando para produto do emissor que foi inativado ou excluído → deve pedir de novo e sobrescrever o vínculo, não travar em "Produto inativo." (teste na Task 3).
2. Usuário cancela a escolha de produto no 2º item → a nota fica exatamente como estava (sem destinatário nem itens parciais) (teste na Task 3).
3. Preço da API com casas decimais num Windows pt-BR (`"precoUnitario": 279.9`) → `279,90` na nota, nunca `2799` (teste na Task 2).
4. Token expirado no meio do uso (401) → um novo login automático e a chamada repetida uma vez; 401 de novo vira erro claro (teste na Task 2).
5. Mesmo produto da API em dois pedidos diferentes → a segunda importação usa o vínculo sem perguntar (teste na Task 3).

---

### Task 1: Banco, modelo e repositórios

**Files:**
- Create: `database/005_pedido_api.sql`, `src/Repositories/Repository.VinculoProduto.pas`
- Modify: `src/Models/Model.Nota.pas`, `src/Repositories/Repository.Nota.pas`, `src/Repositories/Repository.Cliente.pas`, `tests/Test.Fakes.pas`, `EmissorNFe.dpr`, `README.md` (tabela de migrações)
- Test: verificação da migração no banco local (probe) + suíte existente

**Interfaces:**
- Produces:
  - `TNota.PedidoApiId: Integer` (0 = nota digitada), gravado/lido em `NOTA.PEDIDO_API_ID` (nulo quando 0).
  - `INotaRepository.ObterFaturadaDoPedido(APedidoApiId: Integer): TNota` — nota Autorizada ou em Contingência com esse pedido (a mais recente), ou `nil`. Sem itens/pagamentos carregados.
  - `IClienteRepository.ObterPorDocumento(const ADocumento: string): TCliente` — ativo, `CPF_CNPJ` igual ao documento já normalizado, ou `nil`.
  - `IVinculoProdutoRepository` em `Repository.VinculoProduto`: `function ProdutoDoEmissor(AApiProdutoId: Integer): Integer` (0 = sem vínculo) e `procedure Gravar(AApiProdutoId, AProdutoId: Integer)` (insere ou atualiza — `UPDATE OR INSERT ... MATCHING (API_PRODUTO_ID)`). `TVinculoProdutoRepository.Create(AConexao: IConexao)`.
  - Fakes: `TFakeNotaRepository` ganha uma lista de notas faturadas consultável; `TFakeClienteRepository` responde `ObterPorDocumento`; novo `TFakeVinculoRepository` (dicionário em memória).

- [ ] **Step 1:** Escrever `005_pedido_api.sql`: `ALTER TABLE NOTA ADD PEDIDO_API_ID INTEGER;`, índice `IX_NOTA_PEDIDO_API`, tabela `PRODUTO_VINCULO_API (API_PRODUTO_ID INTEGER NOT NULL PK, PRODUTO_ID INTEGER NOT NULL FK PRODUTO(ID), CRIADO_EM TIMESTAMP DEFAULT LOCALTIMESTAMP NOT NULL)`, `COMMIT;`.
- [ ] **Step 2:** Rodar o emissor (ou um probe com `Infra.Migracao`) contra o banco local.
  Expected: `SCHEMA_VERSAO` contém `005_pedido_api.sql`; `SELECT PEDIDO_API_ID FROM NOTA` e `SELECT * FROM PRODUTO_VINCULO_API` executam.
- [ ] **Step 3:** Implementar `PedidoApiId` no modelo e no `GravarCabecalho`/leitura de `Repository.Nota`; `ObterFaturadaDoPedido`; `ObterPorDocumento`; `Repository.VinculoProduto`; fakes; `uses` do `.dpr`; linha 005 no README.
- [ ] **Step 4:** Probe contra o banco local: salvar nota com `PedidoApiId = 12`, relê-la (vem 12); `Gravar(7, 1)` duas vezes e `Gravar(7, 2)` → `ProdutoDoEmissor(7) = 2`.
  Expected: valores conferem, sem erro de chave.
- [ ] **Step 5:** Compilar `EmissorNFe.dpr` e rodar `tests/EmissorNFeTests.dpr`.
  Expected: compila sem erro; todos os testes existentes passam.
- [ ] **Step 6: Commit** — `Adiciona vínculo de produto e pedido da API na nota`

### Task 2: Configuração e cliente da API

**Files:**
- Create: `src/Models/Model.PedidoApi.pas`, `src/Infra/Infra.ApiPedidos.pas`, `tests/Test.ApiPedidos.pas`
- Modify: `src/Infra/Infra.Config.pas`, `config.example.ini`, `EmissorNFe.dpr`, `tests/EmissorNFeTests.dpr`

**Interfaces:**
- Produces:
  - `Model.PedidoApi`: `TStatusPedidoApi = (Aberto, Cancelado)`; `TItemPedidoApi` (`ProdutoId: Integer`, `Descricao: string`, `Quantidade: Integer`, `PrecoUnitario: Currency`, `ValorTotal: Currency`); `TPedidoApi` (`Id`, `ClienteId: Integer`, `ClienteNome: string`, `Data: TDateTime`, `Status: TStatusPedidoApi`, `ValorTotal: Currency`, `Itens: TObjectList<TItemPedidoApi>`, mais `NotaNumero: Integer` preenchido pelo Service para a lista); `TClienteApi` (`Id`, `Nome`, `Documento`, `Email`, `Telefone`); `TPaginaPedidosApi` (`Pagina`, `Total: Integer`, `Pedidos: TObjectList<TPedidoApi>`, `TotalPaginas(ALimite)`).
  - `Infra.Config`: `TConfig.Api: TConfigApi` com `Url`, `Usuario`, `Senha: string`, `TimeoutMs: Integer`. Seção `[Api]`: `Url` (padrão `http://localhost:9000`), `Usuario`, `Senha`, `TimeoutSegundos` (padrão 15).
  - `Infra.ApiPedidos`:
    - `THttpResposta = record Status: Integer; Corpo: string; end;`
    - `IHttpTransporte.Executar(const AMetodo, AUrl, ACorpo, AToken: string): THttpResposta` — implementação `TNetHttpTransporte.Create(ATimeoutMs)` sobre `THTTPClient`; falha de conexão (`ENetException`) vira `EApiPedidos` com `'Não foi possível conectar à API em %s.'`.
    - `EApiPedidos = class(Exception)`.
    - `IPedidoApi`: `function Listar(APagina, ALimite: Integer): TPaginaPedidosApi`, `function Obter(AId: Integer): TPedidoApi`, `function ObterCliente(AId: Integer): TClienteApi`.
    - `TPedidoApiHttp.Create(ATransporte: IHttpTransporte; const AUrl, AUsuario, ASenha: string)`. Login (`POST /auth/login`, `{"login","senha"}` → `token`) na primeira chamada; 401 → novo login e repete uma vez. Status ≥ 400 vira `EApiPedidos` com o `erro` do JSON (ou `'A API respondeu %d.'` sem corpo). Rotas: `/pedidos?pagina=&limite=`, `/pedidos/:id`, `/clientes/:id`. Resposta paginada: `pagina`, `limite`, `total`, `dados`.
    - Números do JSON lidos como `TJSONNumber` (ponto decimal independe do Windows).
    - Falha de conexão e status ≥ 500 registram `Log.Erro` com método, URL e status (nunca a senha nem o token).

- [ ] **Step 1: Testes que falham** em `Test.ApiPedidos.pas`, com um `TTransporteFake` que devolve respostas em fila e registra as chamadas:
  - `Obter_ConvertePedidoComItens`: JSON `{"id":12,"cliente":{"id":3,"nome":"Maria Souza"},"data":"2026-11-20T10:30:00","status":"ABERTO","valorTotal":559.8,"itens":[{"id":1,"produtoId":7,"descricao":"Teclado","quantidade":2,"precoUnitario":279.9,"valorTotal":559.8}]}` → `Id=12`, `ClienteId=3`, `Status=Aberto`, 1 item com `ProdutoId=7`, `Quantidade=2`, `PrecoUnitario=279.90`.
  - `Obter_PrecoComPontoEmWindowsPtBr`: com `FormatSettings.DecimalSeparator := ','` durante o teste, `PrecoUnitario = 279.90`.
  - `Obter_StatusCancelado`: `"status":"CANCELADO"` → `Cancelado`.
  - `PrimeiraChamada_FazLoginEEnviaToken`: 1ª chamada ao transporte é `POST .../auth/login` com `login`/`senha` do construtor; a 2ª leva o token devolvido.
  - `Resposta401_RelogaERepeteUmaVez`: fila `login 200`, `401`, `login 200`, `200 pedido` → retorna o pedido; 4 chamadas.
  - `Resposta401DuasVezes_LevantaErro`: `login`, `401`, `login`, `401` → `EApiPedidos`.
  - `Erro422_UsaMensagemDaApi`: `{"erro":"Pedido 99 não encontrado."}` com 404 → `EApiPedidos` com essa mensagem.
  - `Listar_LePagina`: `{"pagina":1,"limite":20,"total":45,"dados":[...2 pedidos...]}` → `Total=45`, 2 pedidos, `TotalPaginas(20)=3`.
- [ ] **Step 2:** Compilar a suíte. Expected: falha de compilação/RED pelas units inexistentes.
- [ ] **Step 3:** Implementar `Model.PedidoApi`, `Infra.ApiPedidos`, a seção `[Api]` em `Infra.Config` e no `config.example.ini` (com `; usuário do seed da API em desenvolvimento: admin` e `Senha=` vazia).
- [ ] **Step 4:** Rodar a suíte. Expected: os testes novos e os antigos passam.
- [ ] **Step 5:** Probe contra a API real em `localhost:9000` (`admin`/`admin123` só no `config.ini` local): `Listar(1, 20)` e `Obter` de um pedido existente. Expected: dados iguais aos da API; com a API desligada, a mensagem de conexão.
- [ ] **Step 6: Commit** — `Adiciona cliente da API de pedidos`

### Task 3: Service de faturamento do pedido

**Files:**
- Create: `src/Services/Service.FaturamentoPedido.pas`, `tests/Test.FaturamentoPedido.pas`
- Modify: `src/Services/Service.Nota.pas`, `src/Controllers/Controller.Fabrica.pas`, `tests/Test.Fakes.pas`, `EmissorNFe.dpr`, `tests/EmissorNFeTests.dpr`

**Interfaces:**
- Consumes: Task 1 (`ObterFaturadaDoPedido`, `ObterPorDocumento`, `IVinculoProdutoRepository`, `TNota.PedidoApiId`), Task 2 (`IPedidoApi`, `TPedidoApi`, `TClienteApi`).
- Produces:
  - `INotaService.AdicionarItemComPreco(ANota: TNota; AProdutoId: Integer; AQuantidade, AValorUnitario: Currency)` — igual a `AdicionarItem`, mas o valor unitário vem do parâmetro (recalcula totais).
  - `TCadastrarCliente = reference to function(ACliente: TClienteApi): Integer` (id do cliente criado no emissor; 0 = cancelou).
  - `TEscolherProduto = reference to function(AItem: TItemPedidoApi): Integer` (id do produto do emissor; 0 = cancelou).
  - `IFaturamentoPedidoService`:
    - `function ListarPedidos(APagina, ALimite: Integer): TPaginaPedidosApi` — preenche `NotaNumero` de cada pedido com `ObterFaturadaDoPedido` (0 se não faturado).
    - `function Importar(ANota: TNota; APedidoId: Integer; const ACadastrarCliente: TCadastrarCliente; const AEscolherProduto: TEscolherProduto): Boolean` — `False` = usuário cancelou, nota intacta.
  - `TFabrica.FaturamentoPedidoService: IFaturamentoPedidoService` (monta `TPedidoApiHttp` com `Config.Api`).
  - Regras de `Importar`, nesta ordem: nota precisa ser NF-e (modelo 55), editável e sem itens (`'Importe o pedido numa NF-e nova, sem itens.'`); pedido `Cancelado` → `EValidacao` `'Pedido cancelado na API não pode ser faturado.'`; nota faturada existente → `'Pedido %d já faturado na NF-e %d.'`; resolve cliente (`TDocumento.Normalizar` + `ObterPorDocumento`; ausente → `ObterCliente` da API + callback); resolve cada item (vínculo cujo produto existe e está ativo; senão callback e `Gravar`); **só depois de tudo resolvido** aplica na nota: `ClienteId`, itens via `AdicionarItemComPreco` (quantidade e preço do pedido), `Observacao := 'Pedido nº %d (delphi-horse-api)'`, `PedidoApiId`; registra `Log.Info` (`'Pedido %d importado na nota'`) e um `Log.Info` por vínculo criado.

- [ ] **Step 1: Testes que falham** em `Test.FaturamentoPedido.pas` (fakes de `IPedidoApi`, repositórios e `INotaService` real com fakes de `Test.Fakes`):
  - `PedidoCancelado_Recusa` → `EValidacao` com a mensagem exata; nota sem itens.
  - `PedidoComNotaAutorizada_Recusa` → mensagem `'Pedido 12 já faturado na NF-e 345.'`.
  - `PedidoComNotaRejeitada_Importa` → o fake de nota não devolve faturada; `Importar = True`.
  - `ClienteEncontradoPeloDocumento_NaoChamaCallback` → documento `'123.456.789-09'` na API acha `CpfCnpj='12345678909'`; callback de cliente não chamado; `ANota.ClienteId` = id do cliente.
  - `ClienteAusente_ChamaCallbackComDadosDaApi` → callback recebe `Nome`, `Documento`, `Email` da API; id devolvido vai para a nota.
  - `ClienteAusente_CallbackCancela_NotaIntacta` → `Importar = False`; `ClienteId=0`, sem itens, `PedidoApiId=0`.
  - `VinculoExistente_UsaSemPerguntar` → callback de produto não chamado.
  - `VinculoAusente_PerguntaEGrava` → callback chamado 1 vez; `ProdutoDoEmissor(7)` passa a devolver o id escolhido.
  - `VinculoParaProdutoInativo_PerguntaDeNovo` → vínculo 7→1 com produto 1 inativo; callback chamado; vínculo sobrescrito.
  - `CancelaNoSegundoItem_NotaIntacta` → 2 itens; callback do 2º devolve 0; `Importar = False`; nota sem itens e sem cliente.
  - `PrecoEQuantidadeVemDoPedido` → produto do emissor com `Preco=300`; pedido com `279,90 × 2`; item com `ValorUnitario=279.90`, `Quantidade=2`; `ValorTotal` da nota `559.80`.
  - `DemaisDadosFiscaisVemDoEmissor` → item com `NCM`, `CFOP` e `CstCsosn` do produto do emissor.
  - `GravaPedidoEObservacao` → `PedidoApiId=12`; `Observacao='Pedido nº 12 (delphi-horse-api)'`.
  - `NotaComItens_Recusa` → `'Importe o pedido numa NF-e nova, sem itens.'`.
  - `ListarPedidos_PreencheNumeroDaNota` → pedido faturado com `NotaNumero=345`, o outro com 0.
- [ ] **Step 2:** Rodar a suíte. Expected: RED (unit/método inexistente).
- [ ] **Step 3:** Implementar `AdicionarItemComPreco` (reaproveitar o corpo de `AdicionarItem`), `Service.FaturamentoPedido` e a fábrica.
- [ ] **Step 4:** Rodar a suíte. Expected: todos passam.
- [ ] **Step 5: Commit** — `Adiciona importação de pedido da API na NF-e`

### Task 4: Telas e controllers

**Files:**
- Create: `src/Controllers/Controller.PedidoApi.pas`, `src/Views/View.PedidoApi.pas/.dfm`, `src/Views/View.VinculoProduto.pas/.dfm`
- Modify: `src/Controllers/Controller.Nota.pas`, `src/Views/View.Nota.pas/.dfm`, `src/Views/View.Cliente.pas`, `EmissorNFe.dpr`

**Interfaces:**
- Consumes: Task 3 (`IFaturamentoPedidoService`, callbacks).
- Produces:
  - `TPedidoApiController` (class methods): `Listar(APagina: Integer): TPaginaPedidosApi` (20 por página).
  - `TNotaController.ImportarPedido(APedidoId: Integer; const ACadastrarCliente: TCadastrarCliente; const AEscolherProduto: TEscolherProduto): Boolean`.
  - `TfrmPedidoApi.Escolher: Integer` (class function; id do pedido ou 0). Grid com Nº, Data, Cliente, Total, Status, Nota; botões Anterior/Próxima, Escolher, Cancelar. Pedido cancelado ou com nota: botão Escolher desabilitado e motivo num rótulo.
  - `TfrmVinculoProduto.Escolher(AItem: TItemPedidoApi): Integer` (class function): mostra descrição, quantidade e preço do item da API e um `TcxLookupComboBox` com os produtos ativos do emissor (código — descrição).
  - `TfrmCliente.CadastrarComDados(const ANome, ADocumento, AEmail, ATelefone: string): Integer` (class function): abre o cadastro em modo "novo" já preenchido; devolve o id salvo ou 0.
  - `View.Nota`: `btnImportarPedido` (`TcxButton`, "Importar pedido") ao lado de `btnAdicionarItem`; visível só na NF-e; habilitado com a nota editável e sem itens. Ao concluir, atualiza cliente, itens, totais e observação na tela. Cursor de espera durante as chamadas à API; erros com a mensagem do Service/API.

- [ ] **Step 1:** Implementar controllers, telas, `.dfm` e o botão.
- [ ] **Step 2:** Compilar `EmissorNFe.dpr`. Expected: sem erros nem avisos novos.
- [ ] **Step 3:** Probe/roteiro contra a API real: pedido com cliente inexistente no emissor (cadastro abre preenchido), produto sem vínculo (escolha), importação concluída; repetir com outro pedido do mesmo produto (sem pergunta); pedido cancelado (bloqueado). Expected: nota com destinatário, itens com o preço do pedido, observação e totais corretos.
- [ ] **Step 4:** Rodar a suíte. Expected: todos passam.
- [ ] **Step 5:** Prints `docs/screenshots/importar-pedido.png`, `vinculo-produto.png`, `nota-pedido-importado.png`.
- [ ] **Step 6: Commit** — `Adiciona telas de importação de pedido da API`

### Task 5: READMEs dos três projetos

**Files:**
- Modify: `README.md` (emissor), `C:\Projetos\Portifolio\GitHub\delphi-horse-api\delphi-horse-api\README.md`, `C:\Projetos\Portifolio\GitHub\delphi-vcl-client\README.md`

- [ ] **Step 1: Emissor** — em Funcionalidades: "Faturamento de pedidos da delphi-horse-api" (o fluxo em 4–5 linhas); em Como executar: a seção `[Api]` do `config.ini`; Arquitetura: `Infra.ApiPedidos` e `Service.FaturamentoPedido`; Migrações: linha do 005 (se ainda não houver); Roadmap: item marcado; prints novos; linha de ecossistema no topo ligando API e cliente.
- [ ] **Step 2: API** — linha de ecossistema: o cliente desktop cria os pedidos e o emissor fatura esses pedidos como NF-e (links para os dois repositórios).
- [ ] **Step 3: Cliente** — linha de ecossistema: os pedidos criados aqui podem ser faturados como NF-e no delphi-emissor-nfe (link).
- [ ] **Step 4:** Conferir os links e as imagens (arquivos existem nos caminhos citados).
- [ ] **Step 5: Commits** — um por repositório: `Documenta o faturamento de pedidos da API` (emissor), `Aponta o emissor de NF-e no README` (API e cliente).
