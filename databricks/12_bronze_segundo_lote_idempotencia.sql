-- SEGUNDO LOTE: CLIMA
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

-- SEGUNDO LOTE: MUNICÍPIOS
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

-- CONFERÊNCIA DA BRONZE
SELECT
    'Clima' AS fonte,
    COUNT(*) AS registros_bronze
FROM workspace.sinal_cidadao.bronze_clima

UNION ALL

SELECT
    'Municípios' AS fonte,
    COUNT(*) AS registros_bronze
FROM workspace.sinal_cidadao.bronze_municipios;
