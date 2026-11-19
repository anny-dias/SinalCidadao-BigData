SELECT
    'Clima' AS fonte,
    COUNT(*) AS registros_bronze
FROM workspace.sinal_cidadao.bronze_clima

UNION ALL

SELECT
    'Municípios' AS fonte,
    COUNT(*) AS registros_bronze
FROM workspace.sinal_cidadao.bronze_municipios;
