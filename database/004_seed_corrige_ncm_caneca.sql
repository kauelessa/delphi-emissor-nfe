/*
  Corrige o NCM da caneca de exemplo do 003: 6911.10.00 não existe na TIPI
  (a posição se divide em 6911.10.10 e 6911.10.90) e a SEFAZ rejeita com 778.
  Caneca de porcelana entra em 6911.10.90 - Outros.
*/

UPDATE PRODUTO SET NCM = '69111090'
WHERE CODIGO = '0002' AND NCM = '69111000';

COMMIT;
