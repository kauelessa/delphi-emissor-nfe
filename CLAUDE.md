# CLAUDE.md

Instruções para o Claude Code neste repositório.

## Sobre o projeto

Emissor de NF-e (modelo 55) e NFC-e (modelo 65) em Delphi VCL, usando os componentes ACBr e banco Firebird 5.0. Faz parte do portfólio público de Kauê Lessa (Desenvolvedor Delphi Sênior), então o código deve ser limpo, bem organizado e servir de vitrine de boas práticas.

## Ambiente

- Delphi / RAD Studio (Community Edition ou superior). A compilação e o design de forms são feitos no RAD Studio; o Claude Code edita `.pas`, `.dpr`, scripts SQL e documentação pelo VS Code.
- Não altere manualmente `.dproj`, `.res` ou `.dfm`, a menos que seja pedido explicitamente. Se uma unit nova precisar ser adicionada ao projeto, avise para incluí-la pelo RAD Studio (ou atualize o `uses` do `.dpr` e informe). Quando um form precisar de componentes novos, descreva quais adicionar e com quais nomes.
- Componentes ACBr instalados na IDE pelo instalador oficial (não versionar fontes do ACBr no repositório).
- Banco: Firebird 5.0 via FireDAC. Scripts SQL ficam em `database/`, numerados (`001_create_tables.sql`, `002_...`).

## Interface (UI)

- Sempre dar preferência aos componentes do **DevExpress VCL Controls v26.1.5** nas telas. Exemplos: `TcxGrid` para grades; `TcxTextEdit`, `TcxMaskEdit`, `TcxCurrencyEdit`, `TcxDateEdit` e `TcxLookupComboBox` para campos; `TdxLayoutControl` para o layout dos forms; `TcxPageControl` para abas; `TdxBarManager` ou `TdxRibbon` para menus; `TdxSkinController` para o tema visual.
- Usar componentes padrão da VCL apenas quando não houver equivalente DevExpress adequado, explicando o motivo.
- Ao sugerir componentes para um form, informar a classe DevExpress, o nome proposto e as propriedades principais a configurar.
- Usar apenas recursos e APIs disponíveis na versão 26.1.5; se algo depender de outra versão, avisar antes.

## Regras fiscais e de segurança (obrigatórias)

- Ambiente **sempre homologação** (`taHomologacao`) por padrão. Nunca deixar produção como padrão no código ou no `config.example.ini`.
- **Nunca** versionar certificado digital (`*.pfx`, `*.p12`), senhas, CNPJ/IE reais ou XMLs autorizados. Tudo vem de `config.ini` (não versionado), com um `config.example.ini` de exemplo usando dados fictícios.
- Validar o XML (schemas) antes de transmitir e tratar os códigos de retorno da SEFAZ (cStat), exibindo mensagens claras ao usuário.
- Toda operação fiscal (emissão, cancelamento, CC-e, inutilização) deve registrar log e salvar o XML de envio/retorno.

## Arquitetura

Camadas, em `src/`:

- `Views/` — forms VCL. Apenas interface: sem SQL e sem chamadas diretas ao ACBr.
- `Controllers/` — recebem ações das telas, chamam os Services e devolvem dados para exibição.
- `Services/` — regras de negócio e fluxo fiscal. Concentram o uso do ACBr (montagem da nota, envio, eventos, DANFE).
- `Repositories/` — único lugar com SQL/FireDAC. Sempre usar parâmetros (nunca concatenar valores em SQL).
- `Models/` — entidades e DTOs (Emitente, Cliente, Produto, Nota, ItemNota, Pagamento).
- `Infra/` — conexão, configuração (`config.ini`), logs e utilitários.

Use interfaces (`INotaService`, `IProdutoRepository`) para permitir testes com DUnitX.

## Padrões de código

- Nomes de units: `<Camada>.<Entidade>.pas` (ex.: `View.Nota.pas`, `Service.Nota.pas`, `Repository.Produto.pas`).
- Classes com prefixo `T`, interfaces com `I`, campos privados com `F`, parâmetros com `A` (ex.: `AId`).
- Identificadores em português para o domínio (Nota, Produto, Cliente); termos técnicos podem ficar em inglês.
- Sempre liberar objetos com `try..finally` ou usar interfaces com contagem de referência.
- Valores monetários com `Currency`; arredondamentos conforme as regras da NF-e.

## Testes

- DUnitX em `tests/`. Regras de cálculo (totais, impostos, arredondamento) e validações devem ter teste.
- Repositórios e a comunicação com a SEFAZ são substituídos por mocks/fakes nos testes de Service.

## Git

- Commits pequenos, em português, no imperativo: `Adiciona emissão de NFC-e`, `Corrige cálculo do ICMS`.
- Ao concluir uma funcionalidade, marcar o item no roadmap do `README.md` e adicionar prints em `docs/screenshots/`.
