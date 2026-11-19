-- RELATÓRIO DE QUALIDADE - CAMADA PRATA CLIMA
-- Projeto Sinal Cidadão - Big Data

-- Q1: Data e hora inválidas
SELECT
    'Q1 - Data/hora inválida' AS regra,
    COUNT(*) AS registros_rejeitados
FROM workspace.sinal_cidadao.vw_candidatos_clima
WHERE data_hora IS NULL

UNION ALL

-- Q2: Temperatura inválida
SELECT
    'Q2 - Temperatura inválida' AS regra,
    COUNT(*) AS registros_rejeitados
FROM workspace.sinal_cidadao.vw_candidatos_clima
WHERE temperatura_c IS NULL
   OR temperatura_c < -30
   OR temperatura_c > 60

UNION ALL

-- Q3: Precipitação inválida
SELECT
    'Q3 - Precipitação inválida' AS regra,
    COUNT(*) AS registros_rejeitados
FROM workspace.sinal_cidadao.vw_candidatos_clima
WHERE precipitacao_mm IS NULL
   OR precipitacao_mm < 0;
