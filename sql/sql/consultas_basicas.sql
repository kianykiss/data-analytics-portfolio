-- Exemplo de análise de vendas
-- Considera uma tabela fictícia chamada vendas

SELECT
    produto,
    COUNT(*) AS quantidade_vendas,
    SUM(valor) AS faturamento_total,
    AVG(valor) AS ticket_medio
FROM vendas
GROUP BY produto
ORDER BY faturamento_total DESC;
