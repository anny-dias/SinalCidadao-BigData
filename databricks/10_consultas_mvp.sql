-- CONSULTA 1: Cobertura municipal

SELECT
    COUNT(*) AS total_municipios
FROM workspace.sinal_cidadao.dim_municipio;

-- CONSULTA 2: Temperatura média prevista

SELECT
    m.nome_municipio,
    ROUND(AVG(f.temperatura_c), 2) AS temperatura_media_c,
    ROUND(MIN(f.temperatura_c), 2) AS temperatura_minima_c,
    ROUND(MAX(f.temperatura_c), 2) AS temperatura_maxima_c

FROM workspace.sinal_cidadao.fato_clima f

INNER JOIN workspace.sinal_cidadao.dim_municipio m
    ON f.codigo_ibge = m.codigo_ibge

GROUP BY m.nome_municipio;

-- CONSULTA 3: Precipitação prevista

SELECT
    m.nome_municipio,
    ROUND(SUM(f.precipitacao_mm), 2) AS precipitacao_total_mm,
    SUM(f.indicador_chuva) AS horarios_com_chuva

FROM workspace.sinal_cidadao.fato_clima f

INNER JOIN workspace.sinal_cidadao.dim_municipio m
    ON f.codigo_ibge = m.codigo_ibge

GROUP BY m.nome_municipio;


-- CONSULTA 4: Horários mais quentes

SELECT
    f.data_hora,
    m.nome_municipio,
    f.temperatura_c,
    f.precipitacao_mm

FROM workspace.sinal_cidadao.fato_clima f

INNER JOIN workspace.sinal_cidadao.dim_municipio m
    ON f.codigo_ibge = m.codigo_ibge

ORDER BY f.temperatura_c DESC

LIMIT 10;

-- CONSULTA 5: Indicador de impacto climático potencial

SELECT
    m.nome_municipio,

    COUNT(*) AS total_horarios_analisados,

    SUM(f.indicador_chuva) AS horarios_com_chuva,

    COUNT(*) - SUM(f.indicador_chuva) AS horarios_sem_chuva,

    ROUND(
        100.0 * SUM(f.indicador_chuva) / NULLIF(COUNT(*), 0),
        2
    ) AS percentual_horarios_com_chuva

FROM workspace.sinal_cidadao.fato_clima f

INNER JOIN workspace.sinal_cidadao.dim_municipio m
    ON f.codigo_ibge = m.codigo_ibge

GROUP BY m.nome_municipio;
GROUP BY m.nome_municipio;
