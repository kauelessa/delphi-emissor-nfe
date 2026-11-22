/*
  Aviso de faturamento à delphi-horse-api.
  FATURAMENTO_PENDENTE = 1: a nota foi autorizada ou cancelada mas a API não recebeu o aviso
  (estava fora do ar). O que reenviar sai da situação da nota: autorizada -> PATCH, cancelada -> DELETE.
*/

ALTER TABLE NOTA ADD FATURAMENTO_PENDENTE SMALLINT DEFAULT 0 NOT NULL;

COMMIT;
