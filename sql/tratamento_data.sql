
-- Tratamento de Data
-- Objetivo: converter data textual no formato MM/DD/YYYY
-- para uma string no formato YYYY-MM-DD.

CONCAT(
    SUBSTRING(REPLACE(a.OrderDate, '/', ''), 5, 4),
    '-',
    SUBSTRING(REPLACE(a.OrderDate, '/', ''), 1, 2),
    '-',
    SUBSTRING(REPLACE(a.OrderDate, '/', ''), 3, 2)
) AS DT_CAPTADA
