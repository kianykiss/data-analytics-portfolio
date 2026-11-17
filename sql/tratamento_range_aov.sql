WITH BASE_PEDIDOS AS (
    SELECT
        ID_PEDIDO,
        ROUND(
            SUM(
                COALESCE(RBCFL, 0) +
                COALESCE(VLR_FRETE_PAGO, 0)
            ), 2
        ) AS GMV_PEDIDO
    FROM SUA_TABELA
    GROUP BY ID_PEDIDO
)

SELECT
    ID_PEDIDO,
    GMV_PEDIDO,
    CASE
        WHEN GMV_PEDIDO <= 50 THEN 'Ate R$ 50'
        WHEN GMV_PEDIDO <= 100 THEN 'Entre R$ 50.01 e R$ 100'
        WHEN GMV_PEDIDO <= 150 THEN 'Entre R$ 100.01 e R$ 150'
        WHEN GMV_PEDIDO <= 200 THEN 'Entre R$ 150.01 e R$ 200'
        WHEN GMV_PEDIDO <= 300 THEN 'Entre R$ 200.01 e R$ 300'
        WHEN GMV_PEDIDO <= 400 THEN 'Entre R$ 300.01 e R$ 400'
        ELSE 'Acima de R$ 400'
    END AS AOV_GMV_RANGE
FROM BASE_PEDIDOS;