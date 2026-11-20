# delphi-emissor-nfe

Emissor de **NF-e (modelo 55)** e **NFC-e (modelo 65)** desenvolvido em **Delphi (VCL)** com os componentes **[ACBr](https://projetoacbr.com.br/)** e banco de dados **Firebird**, operando em **ambiente de homologação** da SEFAZ.

> 🚧 Projeto em desenvolvimento — faz parte do meu portfólio. Demonstra o fluxo fiscal completo que uso no dia a dia em ERPs para varejo: cadastro, emissão, transmissão, impressão e eventos da nota.

## 🎯 Funcionalidades

- Configuração do emitente, certificado digital (A1) e ambiente (homologação)
- Cadastro de clientes, produtos (NCM, CFOP, CST/CSOSN) e formas de pagamento
- Emissão de NF-e e NFC-e com validação do XML antes do envio
- Consulta de status do serviço da SEFAZ
- Impressão de DANFE (NF-e) e DANFE NFC-e (cupom com QR Code)
- Eventos: cancelamento, carta de correção (CC-e) e inutilização de numeração
- Contingência offline para NFC-e
- Armazenamento e consulta dos XMLs autorizados
- Envio do XML e do DANFE por e-mail

## 🧱 Tecnologias

| Item | Versão / Ferramenta |
|---|---|
| Linguagem | Delphi (Object Pascal) — VCL |
| Documentos fiscais | ACBrNFe, ACBrDFe, ACBrNFeDANFeRL |
| Banco de dados | Firebird 5.0 |
| Acesso a dados | FireDAC |
| Relatórios | Fortes Report (DANFE via ACBr) |
| Testes | DUnitX |

## 📁 Estrutura

```
delphi-emissor-nfe/
├── src/
│   ├── Views/         # Forms VCL (telas)
│   ├── Controllers/   # Ligação entre telas e regras
│   ├── Services/      # Regras de negócio e fluxo fiscal (ACBr)
│   ├── Repositories/  # Acesso ao banco (FireDAC)
│   ├── Models/        # Entidades e DTOs
│   └── Infra/         # Conexão, configuração, utilitários
├── database/          # Scripts SQL de criação do banco
├── tests/             # Testes unitários (DUnitX)
└── docs/
    └── screenshots/   # Prints das telas e DANFEs gerados
```

## ▶️ Como executar

1. Instale o [Firebird 5.0](https://firebirdsql.org/) e execute os scripts em `database/` para criar o banco.
2. Instale os componentes ACBr no RAD Studio pelo instalador oficial do [Projeto ACBr](https://projetoacbr.com.br/).
3. Copie `config.example.ini` para `config.ini` e preencha os dados de conexão e do emitente.
4. Abra o projeto `.dproj` no RAD Studio, compile e execute.
5. Na tela de configuração, selecione seu certificado digital **A1** e mantenha o ambiente em **homologação**.

> ⚠️ O certificado digital e os dados reais do emitente **nunca** são versionados. Notas emitidas em homologação não têm valor fiscal.

## 🗺️ Roadmap

- [ ] Banco de dados e cadastros (emitente, clientes, produtos)
- [ ] Configuração do ACBr e consulta de status da SEFAZ
- [ ] Emissão de NF-e em homologação + DANFE
- [ ] Emissão de NFC-e + DANFE NFC-e com QR Code
- [ ] Cancelamento, CC-e e inutilização
- [ ] Contingência offline (NFC-e)
- [ ] Envio por e-mail e consulta de XMLs

## 👤 Autor

**Kauê Lessa** — Desenvolvedor Delphi Sênior
[GitHub](https://github.com/kauelessa)
