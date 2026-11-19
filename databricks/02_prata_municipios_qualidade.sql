CREATE OR REPLACE TEMP VIEW candidatos_municipios AS
SELECT
    CAST(municipio.id AS BIGINT) AS codigo_ibge,
    TRIM(municipio.nome) AS nome_municipio,
    coletado_em AS data_coleta
FROM workspace.sinal_cidadao.bronze_municipios
LATERAL VIEW EXPLODE(dados) AS municipio;
SELECT COUNT(*) AS total_municipios
FROM candidatos_municipios;
-- Q1: Verificar códigos IBGE inválidos

SELECT
    'Q1 - Código IBGE inválido' AS regra,
    COUNT(*) AS registros_rejeitados
FROM candidatos_municipios
WHERE codigo_ibge IS NULL
   OR LENGTH(CAST(codigo_ibge AS STRING)) <> 7;
-- Q2: Verificar nomes vazios ou nulos

SELECT
    'Q2 - Nome obrigatório' AS regra,
    COUNT(*) AS registros_rejeitados
FROM candidatos_municipios
WHERE nome_municipio IS NULL
   OR nome_municipio = '';
   -- Q3: Verificar códigos IBGE duplicados

SELECT
    'Q3 - Código duplicado' AS regra,
    COALESCE(SUM(quantidade - 1), 0) AS registros_rejeitados
FROM (
    SELECT
        codigo_ibge,
        COUNT(*) AS quantidade
    FROM candidatos_municipios
    GROUP BY codigo_ibge
    HAVING COUNT(*) > 1
);

-- Relatório consolidado das três regras de qualidade

SELECT
    'Q1 - Código IBGE inválido' AS regra,
    COUNT(*) AS registros_rejeitados
FROM candidatos_municipios
WHERE codigo_ibge IS NULL
   OR LENGTH(CAST(codigo_ibge AS STRING)) <> 7

UNION ALL

SELECT
    'Q2 - Nome obrigatório' AS regra,
    COUNT(*) AS registros_rejeitados
FROM candidatos_municipios
WHERE nome_municipio IS NULL
   OR nome_municipio = ''

UNION ALL

SELECT
    'Q3 - Código duplicado' AS regra,
    COALESCE(SUM(quantidade - 1), 0) AS registros_rejeitados
FROM (
    SELECT
        codigo_ibge,
        COUNT(*) AS quantidade
    FROM candidatos_municipios
    GROUP BY codigo_ibge
    HAVING COUNT(*) > 1
);
