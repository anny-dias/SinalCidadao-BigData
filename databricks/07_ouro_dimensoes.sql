-- CAMADA OURO
-- Dimensão de municípios

CREATE TABLE IF NOT EXISTS workspace.sinal_cidadao.dim_municipio
USING DELTA
AS
SELECT DISTINCT
    codigo_ibge,
    nome_municipio
FROM workspace.sinal_cidadao.prata_municipios
WHERE codigo_ibge IS NOT NULL
  AND nome_municipio IS NOT NULL;
  SELECT COUNT(*) AS total_municipios
FROM workspace.sinal_cidadao.dim_municipio;
-- Dimensão de tempo

CREATE TABLE IF NOT EXISTS workspace.sinal_cidadao.dim_tempo
USING DELTA
AS
SELECT DISTINCT
    data_hora,
    CAST(data_hora AS DATE) AS data_referencia,
    YEAR(data_hora) AS ano,
    MONTH(data_hora) AS mes,
    DAY(data_hora) AS dia,
    HOUR(data_hora) AS hora
FROM workspace.sinal_cidadao.prata_clima
WHERE data_hora IS NOT NULL;
SELECT COUNT(*) AS total_horarios
FROM workspace.sinal_cidadao.dim_tempo;
SELECT
    'dim_municipio' AS tabela,
    COUNT(*) AS total_registros
FROM workspace.sinal_cidadao.dim_municipio

UNION ALL

SELECT
    'dim_tempo' AS tabela,
    COUNT(*) AS total_registros
FROM workspace.sinal_cidadao.dim_tempo;
