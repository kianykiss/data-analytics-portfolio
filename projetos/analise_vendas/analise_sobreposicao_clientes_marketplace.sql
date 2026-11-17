
-- =====================================================
-- PROJETO: Sobreposição de Clientes entre Canais
-- ÁREA: Customer Analytics / Marketplace / Omnichannel
-- DIALETO: Databricks SQL / Spark SQL
-- =====================================================
-- Objetivo:
-- Identificar clientes presentes no marketplace e
-- na base corporativa, classificando documentos
-- compartilhados e sem correspondência.
--
-- Bases demonstrativas:
-- demo.vendas_marketplace
-- demo.pedidos_corporativos
-- =====================================================

WITH BASE_MARKETPLACE AS (
    SELECT
        SUBSTR(CAST(QUEBRA_DATA_2 AS STRING), 1, 7)
            AS ANOMES,
        CASE
            WHEN LENGTH(
                REGEXP_REPLACE(TRIM(CAST(CPF AS STRING)),
                               '[^0-9]', '')
            ) BETWEEN 1 AND 11
            THEN LPAD(
                REGEXP_REPLACE(TRIM(CAST(CPF AS STRING)),
                               '[^0-9]', ''),
                11, '0'
            )
            ELSE REGEXP_REPLACE(
                TRIM(CAST(CPF AS STRING)), '[^0-9]', ''
            )
        END AS DOCUMENTO
    FROM demo.vendas_marketplace
    WHERE MARCA = 'MARCA_EXEMPLO'
      AND CPF IS NOT NULL
),

BASE_CPF_MELI AS (
    SELECT DISTINCT DOCUMENTO AS CPF_MELI
    FROM BASE_MARKETPLACE
    WHERE LENGTH(DOCUMENTO) = 11
),

BASE_MASTER AS (
    SELECT DISTINCT
        a.MODELO_COMERCIAL,
        LPAD(
            REGEXP_REPLACE(
                TRIM(CAST(a.CPF AS STRING)), '[^0-9]', ''
            ), 11, '0'
        ) AS CPF_MASTER,
        b.CPF_MELI,
        a.DT_CAPTADA
    FROM demo.pedidos_corporativos AS a
    INNER JOIN BASE_CPF_MELI AS b
        ON LPAD(
            REGEXP_REPLACE(
                TRIM(CAST(a.CPF AS STRING)), '[^0-9]', ''
            ), 11, '0'
        ) = b.CPF_MELI
    WHERE a.MARCA = 'MARCA_EXEMPLO'
      AND a.CANAL = 'ONLINE'
      AND a.PAIS = 'BRASIL'
      AND LENGTH(
          REGEXP_REPLACE(
              TRIM(CAST(a.CPF AS STRING)), '[^0-9]', ''
          )
      ) BETWEEN 1 AND 11
),

BASE_RANKING AS (
    SELECT
        CPF_MASTER,
        CPF_MELI,
        MODELO_COMERCIAL,
        ROW_NUMBER() OVER (
            PARTITION BY CPF_MASTER
            ORDER BY DT_CAPTADA DESC,
                     MODELO_COMERCIAL ASC
        ) AS ROW_N
    FROM BASE_MASTER
),

BASE_MARCACAO AS (
    SELECT
        CPF_MELI,
        MODELO_COMERCIAL
    FROM BASE_RANKING
    WHERE ROW_N = 1
),

BASE_FINAL AS (
    SELECT
        m.ANOMES,
        r.MODELO_COMERCIAL,
        CASE
            WHEN r.CPF_MELI IS NOT NULL
                THEN 'CPF COMUM'
            ELSE 'SEM CORRESPONDENCIA'
        END AS TIPO_CPF,
        CASE
            WHEN LENGTH(m.DOCUMENTO) = 11 THEN 'CPF'
            WHEN LENGTH(m.DOCUMENTO) = 14 THEN 'CNPJ'
            ELSE 'OUTRO'
        END AS TIPO_DOCUMENTO,
        m.DOCUMENTO
    FROM BASE_MARKETPLACE AS m
    LEFT JOIN BASE_MARCACAO AS r
        ON m.DOCUMENTO = r.CPF_MELI
)

SELECT
    ANOMES,
    MODELO_COMERCIAL,
    TIPO_CPF,
    TIPO_DOCUMENTO,
    COUNT(DISTINCT DOCUMENTO) AS DOCUMENTOS_UNICOS
FROM BASE_FINAL
WHERE DOCUMENTO IS NOT NULL
  AND DOCUMENTO <> ''
GROUP BY
    ANOMES,
    MODELO_COMERCIAL,
    TIPO_CPF,
    TIPO_DOCUMENTO
ORDER BY
    ANOMES,
    TIPO_CPF,
    MODELO_COMERCIAL;