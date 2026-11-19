-- =====================================================
-- SINAL CIDADÃO - CAMADA OURO
-- Atualização da tabela fato de condições climáticas
-- =====================================================

CREATE OR REPLACE TABLE workspace.sinal_cidadao.fato_clima
USING DELTA
AS
SELECT
    m.codigo_ibge,
    t.data_hora,
    c.latitude,
    c.longitude,
    c.temperatura_c,
    c.precipitacao_mm,

    CASE
        WHEN c.precipitacao_mm > 0 THEN 1
        ELSE 0
    END AS indicador_chuva

FROM workspace.sinal_cidadao.prata_clima AS c

INNER JOIN workspace.sinal_cidadao.dim_tempo AS t
    ON c.data_hora = t.data_hora

INNER JOIN workspace.sinal_cidadao.dim_municipio AS m
    ON m.codigo_ibge = 3550308;


-- =====================================================
-- 1. QUANTIDADE DE REGISTROS NA OURO
-- =====================================================

SELECT
    COUNT(*) AS total_registros
FROM workspace.sinal_cidadao.fato_clima;


-- =====================================================
-- 2. CONSULTAR OS DADOS DA TABELA FATO
-- =====================================================

SELECT
    m.nome_municipio,
    t.data_referencia,
    t.hora,
    f.temperatura_c,
    f.precipitacao_mm,
    f.indicador_chuva

FROM workspace.sinal_cidadao.fato_clima AS f

INNER JOIN workspace.sinal_cidadao.dim_municipio AS m
    ON f.codigo_ibge = m.codigo_ibge

INNER JOIN workspace.sinal_cidadao.dim_tempo AS t
    ON f.data_hora = t.data_hora

ORDER BY t.data_hora

LIMIT 10;


-- =====================================================
-- 3. VERIFICAR DUPLICAÇÕES
-- =====================================================

SELECT
    codigo_ibge,
    data_hora,
    COUNT(*) AS quantidade

FROM workspace.sinal_cidadao.fato_clima

GROUP BY
    codigo_ibge,
    data_hora

HAVING COUNT(*) > 1;
