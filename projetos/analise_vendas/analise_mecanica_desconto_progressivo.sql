--Análise de Mecânica Promocional — Desconto Progressivo.

WITH BASE1 AS (
    SELECT DISTINCT
        ORD.DT_CAPTADA,
        ORD.CD_PEDIDO,
        ORD.DC_SITUACAOPAGAMENTO,
        MEC.TIPO,
        ORD.CD_VENDA_ITEM,
        ORD.DC_VENDA_ITEM,
        CASE
            WHEN ORD.CD_VENDA_KIT IS NULL OR ORD.CD_VENDA_KIT = '' THEN ORD.CD_VENDA_ITEM
            ELSE ORD.CD_VENDA_KIT
        END AS SKU_KIT,
        CASE
            WHEN ORD.CD_VENDA_KIT IS NULL OR ORD.CD_VENDA_KIT = '' THEN ORD.DC_VENDA_ITEM
            ELSE ORD.DC_VENDA_KIT
        END AS ITEM_KIT,
        ROUND(SUM(ORD.QT_ITENS), 2) AS ITENS,
        ROUND(SUM(ORD.RB_FRETE), 2) AS RB_FRETE

    FROM sandbox.canal_online.kd_full_commerce_online AS ORD

    LEFT JOIN sandbox.canal_online.tb_grade_de_mecanicas AS MEC --apenas uma linha por produto por mecênica
        ON ORD.DT_CAPTADA BETWEEN MEC.DT_INI AND MEC.DT_FIM
        AND REPLACE(
            CASE
                WHEN ORD.CD_VENDA_KIT IS NULL OR ORD.CD_VENDA_KIT = '' THEN ORD.CD_VENDA_ITEM
                ELSE ORD.CD_VENDA_KIT
            END,
            'NATBRA-',
            ''
        ) = CAST(MEC.SKU AS STRING)

    WHERE ORD.MARCA = 'NATURA'
      AND ORD.DC_SITUACAOPAGAMENTO = 'PAGO'
      AND MEC.TIPO = 'PROGRESSIVO'

    GROUP BY ALL
),

BASE2 AS (
    SELECT
        DT_CAPTADA,
        CD_PEDIDO,
        TIPO AS MARCACAO_PROGRESSIVO,
        CASE
            WHEN ROUND(SUM(ITENS), 2) < 2 THEN 'MENOR QUE 2'
            WHEN ROUND(SUM(ITENS), 2) = 2 THEN 'IGUAL A 2'
            WHEN ROUND(SUM(ITENS), 2) = 3 THEN 'IGUAL A 3'
            WHEN ROUND(SUM(ITENS), 2) = 4 THEN 'IGUAL A 4'
            WHEN ROUND(SUM(ITENS), 2) >= 5 THEN 'MAIOR OU IGUAL A 5'
        END AS STATUS_ITENS, --sempre itens inteiros
        ROUND(SUM(RB_FRETE), 2) AS RB_FRETE, --receita nível item
        ROUND(SUM(ITENS), 2) AS UNIDADES

    FROM BASE1

    GROUP BY ALL
)

SELECT
    DT_CAPTADA,
    STATUS_ITENS,
    COUNT(DISTINCT CD_PEDIDO) AS QT_PEDIDOS,
    ROUND(SUM(UNIDADES), 2) AS TOTAL_UNIDADES,
    ROUND(SUM(RB_FRETE), 2) AS TOTAL_FRETE
FROM BASE2
GROUP BY ALL
ORDER BY DT_CAPTADA, STATUS_ITENS;
