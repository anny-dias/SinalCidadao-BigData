-- Criar tabela definitiva da camada Prata de clima

CREATE TABLE IF NOT EXISTS workspace.sinal_cidadao.prata_clima (
    latitude DOUBLE,
    longitude DOUBLE,
    data_hora TIMESTAMP,
    temperatura_c DOUBLE,
    precipitacao_mm DOUBLE,
    data_coleta TIMESTAMP
)
USING DELTA;

-- Inserir ou atualizar registros climáticos

MERGE INTO workspace.sinal_cidadao.prata_clima AS destino

USING (
    SELECT
        latitude,
        longitude,
        data_hora,
        temperatura_c,
        precipitacao_mm,
        data_coleta
    FROM (
        SELECT
            latitude,
            longitude,
            data_hora,
            temperatura_c,
            precipitacao_mm,
            data_coleta,

            ROW_NUMBER() OVER (
                PARTITION BY latitude, longitude, data_hora
                ORDER BY data_coleta DESC
            ) AS numero_linha

        FROM workspace.sinal_cidadao.vw_candidatos_clima

        WHERE data_hora IS NOT NULL
          AND latitude BETWEEN -90 AND 90
          AND longitude BETWEEN -180 AND 180
          AND temperatura_c BETWEEN -30 AND 60
          AND precipitacao_mm IS NOT NULL
          AND precipitacao_mm >= 0
          AND data_coleta IS NOT NULL
    )

    WHERE numero_linha = 1
) AS origem

ON destino.latitude = origem.latitude
AND destino.longitude = origem.longitude
AND destino.data_hora = origem.data_hora

WHEN MATCHED AND origem.data_coleta >= destino.data_coleta THEN
    UPDATE SET
        destino.temperatura_c = origem.temperatura_c,
        destino.precipitacao_mm = origem.precipitacao_mm,
        destino.data_coleta = origem.data_coleta

WHEN NOT MATCHED THEN
    INSERT (
        latitude,
        longitude,
        data_hora,
        temperatura_c,
        precipitacao_mm,
        data_coleta
    )
    VALUES (
        origem.latitude,
        origem.longitude,
        origem.data_hora,
        origem.temperatura_c,
        origem.precipitacao_mm,
        origem.data_coleta
    );

SELECT COUNT(*) AS total_registros
FROM workspace.sinal_cidadao.prata_clima;

SELECT
    data_hora,
    temperatura_c,
    precipitacao_mm
FROM workspace.sinal_cidadao.prata_clima
ORDER BY data_hora
LIMIT 10;

SELECT
    latitude,
    longitude,
    data_hora,
    COUNT(*) AS quantidade
FROM workspace.sinal_cidadao.prata_clima
GROUP BY
    latitude,
    longitude,
    data_hora
HAVING COUNT(*) > 1;
