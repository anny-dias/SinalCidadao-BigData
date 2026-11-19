-- Transformar os arrays climáticos em registros individuais

CREATE OR REPLACE TEMP VIEW candidatos_clima AS

SELECT
    TRY_CAST(dados.latitude AS DOUBLE) AS latitude,
    TRY_CAST(dados.longitude AS DOUBLE) AS longitude,

    TRY_CAST(hora_texto AS TIMESTAMP) AS data_hora,

    TRY_CAST(
        dados.hourly.temperature_2m[posicao]
        AS DOUBLE
    ) AS temperatura_c,

    TRY_CAST(
        dados.hourly.precipitation[posicao]
        AS DOUBLE
    ) AS precipitacao_mm,

    TRY_CAST(coletado_em AS TIMESTAMP) AS data_coleta

FROM workspace.sinal_cidadao.bronze_clima

LATERAL VIEW POSEXPLODE(dados.hourly.time)
AS posicao, hora_texto;

SELECT COUNT(*) AS total_registros
FROM candidatos_clima;

SELECT
    data_hora,
    temperatura_c,
    precipitacao_mm
FROM candidatos_clima
ORDER BY data_hora



-- Relatório de qualidade dos dados climáticos

SELECT
    'Q1 - Data/hora inválida' AS regra,
    COUNT(*) AS registros_rejeitados
FROM candidatos_clima
WHERE data_hora IS NULL

UNION ALL

-- Relatório de qualidade dos dados climáticos

SELECT
    'Q1 - Data/hora inválida' AS regra,
    COUNT(*) AS registros_rejeitados
FROM candidatos_clima
WHERE data_hora IS NULL

UNION ALL

SELECT
    'Q2 - Temperatura inválida' AS regra,
    COUNT(*) AS registros_rejeitados
FROM candidatos_clima
WHERE temperatura_c IS NULL
   OR temperatura_c < -30
   OR temperatura_c > 60

UNION ALL

SELECT
    'Q3 - Precipitação inválida' AS regra,
    COUNT(*) AS registros_rejeitados
FROM candidatos_clima
WHERE precipitacao_mm IS NULL
   OR precipitacao_mm < 0;
   

CREATE OR REPLACE VIEW workspace.sinal_cidadao.vw_candidatos_clima AS

SELECT
    TRY_CAST(dados.latitude AS DOUBLE) AS latitude,
    TRY_CAST(dados.longitude AS DOUBLE) AS longitude,

    TRY_CAST(hora_texto AS TIMESTAMP) AS data_hora,

    TRY_CAST(
        dados.hourly.temperature_2m[posicao]
        AS DOUBLE
    ) AS temperatura_c,

    TRY_CAST(
        dados.hourly.precipitation[posicao]
        AS DOUBLE
    ) AS precipitacao_mm,

    TRY_CAST(coletado_em AS TIMESTAMP) AS data_coleta

FROM workspace.sinal_cidadao.bronze_clima

LATERAL VIEW POSEXPLODE(dados.hourly.time)
AS posicao, hora_texto;

SELECT COUNT(*) AS total_registros
FROM workspace.sinal_cidadao.vw_candidatos_clima;
