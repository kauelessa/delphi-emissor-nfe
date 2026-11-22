# Faturar pedido da API no emissor — desenho

## Intenção

Mostrar o ecossistema do portfólio funcionando de ponta a ponta: um pedido feito no
[delphi-vcl-client](https://github.com/kauelessa/delphi-vcl-client) e gravado na
[delphi-horse-api](https://github.com/kauelessa/delphi-horse-api) é faturado neste emissor
como NF-e, sem redigitar cliente nem itens.

O objetivo é a demonstração para quem avalia o portfólio, não uma operação real de faturamento.
Por isso o controle é o suficiente para ser correto e crível (não faturar duas vezes, dados
fiscais vindos do cadastro certo), sem processos de ERP completo.

## Metas

- Na tela de nota, importar um pedido da API e chegar à nota preenchida (destinatário e itens).
- Os dados fiscais (NCM, CFOP, CST, endereço) vêm sempre do cadastro do emissor.
- Ligar o produto da API ao produto do emissor uma vez só; depois a ligação é automática.
- Impedir faturar de novo um pedido que já tem nota autorizada.

## Fora do escopo

- Alterar a API (não ganha status "faturado"; o controle fica no emissor).
- NFC-e (modelo 65) a partir de pedido.
- Sincronizar cadastros entre API e emissor, ou faturar vários pedidos de uma vez.

## O que não pode acontecer

- Nota com dados fiscais inventados ou padronizados para todos os produtos.
- Pedido cancelado na API virando nota.
- Senha da API versionada.

## Abordagens consideradas

- **A) Vínculo na primeira vez — escolhida.** Produto da API sem vínculo pede para o usuário
  escolher o produto do emissor correspondente, e o vínculo fica gravado. Cliente é localizado
  pelo CPF/CNPJ; se não existir, abre o cadastro já preenchido para completar o endereço.
  Mantém o fiscal correto e mostra a separação comercial (API) × fiscal (emissor).
- **B) Criar automaticamente com dados fiscais padrão do `config.ini`.** Um clique, mas todo
  produto com o mesmo NCM e cliente sem endereço, que a NF-e exige. Descartada.

## O que a API oferece (sem mudanças)

- `POST /auth/login` (`{"login","senha"}` → token JWT de 60 min, sem renovação).
- `GET /pedidos?pagina=&limite=&clienteId=` e `GET /pedidos/:id`: pedido com `status`
  (`ABERTO`/`CANCELADO`), cliente (`id`, `nome`, `documento`) e itens (`produtoId`, descrição,
  `quantidade` inteira, `precoUnitario`, total).
- `GET /clientes/:id` para e-mail e telefone do cliente.

## Fluxo

1. Na tela de nota (`View.Nota`), com uma NF-e nova e vazia, o botão **Importar pedido**
   (`btnImportarPedido`, `TcxButton`) abre a lista de pedidos da API.
2. A lista (`View.PedidoApi`) mostra os pedidos paginados: número, data, cliente, total,
   status, e uma coluna "Nota" com o número da nota do emissor quando já foi faturado.
   Pedidos cancelados aparecem, mas não podem ser escolhidos.
3. Ao escolher um pedido, o Service:
   - recusa pedido `CANCELADO` ("Pedido cancelado na API não pode ser faturado.");
   - recusa pedido que já tem nota **Autorizada** ou em **Contingência** no emissor
     ("Pedido 12 já faturado na NF-e 345."). Nota rejeitada, denegada, cancelada ou em
     digitação não bloqueia;
   - localiza o cliente do emissor pelo CPF/CNPJ (normalizado por `Infra.Documento`).
     Não achou: a tela abre o cadastro de cliente (`View.Cliente`) com nome, documento,
     e-mail e telefone preenchidos; o usuário completa e salva. Se cancelar, a importação para;
   - para cada item, busca o vínculo do produto da API. Sem vínculo: a tela pede o produto do
     emissor correspondente (`View.VinculoProduto`, com `TcxLookupComboBox` dos produtos
     ativos) e grava o vínculo. Se cancelar, a importação para e nada é alterado na nota.
4. A nota recebe o destinatário e os itens. **Quantidade e preço unitário vêm do pedido**
   (é o valor negociado na venda); todo o resto do item vem do produto do emissor.
   A observação da nota recebe "Pedido nº 12 (delphi-horse-api)".
5. A partir daí é a tela de nota de sempre: o usuário informa a forma de pagamento e emite.
   O número do pedido fica gravado na nota (`NOTA.PEDIDO_API_ID`).

## Banco (script novo `database/005_pedido_api.sql`)

- `NOTA.PEDIDO_API_ID INTEGER` (nulo para notas digitadas) e índice nele.
- Tabela `PRODUTO_VINCULO_API`: `API_PRODUTO_ID INTEGER` (PK), `PRODUTO_ID INTEGER NOT NULL`
  (FK `PRODUTO`), `CRIADO_EM TIMESTAMP`.
- Atualizar a tabela de migrações do `README.md`.

## Acesso à API

- Nova seção no `config.ini`: `[Api]` com `Url`, `Usuario`, `Senha` e `TimeoutSegundos`.
  O `config.example.ini` traz `Url=http://localhost:9000`, `Usuario=admin` e `Senha` vazia,
  com comentário apontando o seed da API. Mesmo tratamento da senha do certificado: só no
  `config.ini`, que não é versionado.
- Login na primeira chamada; o token fica em memória. Resposta 401 faz um novo login e repete
  a chamada uma vez.
- API fora do ar ou URL errada: mensagem clara com o endereço ("Não foi possível conectar à
  API em http://localhost:9000."). Erros da API mostram o `{"erro"}` que ela devolve.
- O emissor não tem cliente HTTP hoje; usar `System.Net.HttpClient` (`THTTPClient`).

## Camadas (seguindo o CLAUDE.md)

- `Infra.ApiPedidos` (ou nome equivalente): interface `IPedidoApi` com `Listar` e `Obter`,
  implementação com `THTTPClient`. É o único lugar que fala HTTP; substituível por fake.
- `Models`: `TPedidoApi` / `TItemPedidoApi` (DTOs do pedido vindo da API).
- `Repositories`: `Repository.VinculoProduto` (vínculo) e consultas novas em
  `Repository.Nota` (nota por pedido) e `Repository.Cliente` (cliente por documento, se ainda
  não houver).
- `Services`: `Service.FaturamentoPedido` — valida o pedido, resolve cliente e vínculos e
  preenche a nota. Para o que depende do usuário (cadastrar cliente, escolher produto), recebe
  callbacks da tela, para o Service não conhecer forms.
- `Controllers`: `Controller.Nota` ganha `ImportarPedido`; novo `Controller.PedidoApi` para a
  lista.
- `Views`: `View.PedidoApi` (lista) e `View.VinculoProduto` (escolha do produto), com
  `.dfm` gerado (autorizado neste projeto) e DevExpress (`TcxGrid`, `TdxLayoutControl`).

## Log e rastreabilidade

- Registrar no log do emissor: importação do pedido (nº do pedido → id da nota), vínculos
  criados e falhas de comunicação com a API.

## Testes (DUnitX, sem a API no ar)

- Conversão do JSON do pedido (inclusive preço com ponto decimal num Windows pt-BR).
- `Service.FaturamentoPedido` com fakes de `IPedidoApi` e dos repositórios:
  pedido cancelado é recusado; pedido com nota autorizada é recusado; nota rejeitada não
  bloqueia; cliente encontrado pelo documento; cliente ausente chama o callback e cancelar
  interrompe; vínculo existente é usado; vínculo ausente chama o callback e grava; preço e
  quantidade vêm do pedido; demais campos fiscais vêm do produto do emissor.

## Deixado para quem constrói

- Nomes finais de units e componentes, dentro do padrão do projeto.
- Layout das duas telas novas, no estilo das telas existentes do emissor.
- Paginação da lista de pedidos (sugestão: 20 por página, mais recentes primeiro).

## Decisões tomadas por mim (para revisão do Kauê)

- Preço e quantidade do item vêm do pedido, não do cadastro do emissor.
- Bloqueio de refaturamento só por nota Autorizada ou em Contingência.
- Credenciais da API no `config.ini`, como a senha do certificado.
- Pedido cancelado aparece na lista, mas não pode ser escolhido.
- Observação da nota com o número do pedido.
