CREATE TABLE IF NOT EXISTS workspace.sinal_cidadao.bronze_clima;

CREATE TABLE IF NOT EXISTS workspace.sinal_cidadao.bronze_municipios;
COPY INTO workspace.sinal_cidadao.bronze_clima
FROM '/Volumes/workspace/sinal_cidadao/chegada/clima'
FILEFORMAT = JSON
FORMAT_OPTIONS (
    'mergeSchema' = 'true',
    'multiLine' = 'true'
)
COPY_OPTIONS (
    'mergeSchema' = 'true'
);
SELECT COUNT(*) AS total_registros
FROM workspace.sinal_cidadao.bronze_clima;
COPY INTO workspace.sinal_cidadao.bronze_municipios
FROM '/Volumes/workspace/sinal_cidadao/chegada/municipios'
FILEFORMAT = JSON
FORMAT_OPTIONS (
    'mergeSchema' = 'true',
    'multiLine' = 'true'
)
COPY_OPTIONS (
    'mergeSchema' = 'true'
);
SELECT COUNT(*) AS total_registros
FROM workspace.sinal_cidadao.bronze_municipios;
SELECT
    'Clima' AS fonte,
    COUNT(*) AS registros_bronze
FROM workspace.sinal_cidadao.bronze_clima

UNION ALL

SELECT
    'Municípios' AS fonte,
    COUNT(*) AS registros_bronze
FROM workspace.sinal_cidadao.bronze_municipios;
