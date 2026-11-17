CASE
WHEN ORD.UF_ENDENTR IN ('AC', 'AP', 'AM', 'PA', 'RO', 'RR', 'TO') THEN 'Norte'
WHEN ORD.UF_ENDENTR IN ('AL', 'BA', 'CE', 'MA', 'PB', 'PE', 'PI', 'RN', 'SE') THEN 'Nordeste'
WHEN ORD.UF_ENDENTR IN ('GO', 'MT', 'MS', 'DF') THEN 'Centro-Oeste'
WHEN ORD.UF_ENDENTR IN ('ES', 'MG', 'RJ', 'SP') THEN 'Sudeste'
WHEN ORD.UF_ENDENTR IN ('PR', 'RS', 'SC') THEN 'Sul'
ELSE 'Outros'
END AS REGIAO
