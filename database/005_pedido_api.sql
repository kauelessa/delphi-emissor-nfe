/*
  Faturamento de pedidos da delphi-horse-api.
  - NOTA.PEDIDO_API_ID: pedido da API que originou a nota (nulo nas notas digitadas).
  - PRODUTO_VINCULO_API: qual produto do emissor corresponde a cada produto da API.
    O vínculo é feito pelo usuário na primeira vez que o produto aparece num pedido.
*/

ALTER TABLE NOTA ADD PEDIDO_API_ID INTEGER;

CREATE INDEX IX_NOTA_PEDIDO_API ON NOTA (PEDIDO_API_ID);

CREATE TABLE PRODUTO_VINCULO_API (
  API_PRODUTO_ID  INTEGER NOT NULL,
  PRODUTO_ID      INTEGER NOT NULL,
  CRIADO_EM       TIMESTAMP DEFAULT LOCALTIMESTAMP NOT NULL,
  CONSTRAINT PK_PRODUTO_VINCULO_API PRIMARY KEY (API_PRODUTO_ID),
  CONSTRAINT FK_PRODUTO_VINCULO_API_PRODUTO FOREIGN KEY (PRODUTO_ID) REFERENCES PRODUTO (ID)
);

COMMIT;
