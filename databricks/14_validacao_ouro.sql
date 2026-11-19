-- Conferência das tabelas da camada Ouro

SELECT
    'dim_municipio' AS tabela,
    COUNT(*) AS total_registros
FROM workspace.sinal_cidadao.dim_municipio

UNION ALL

SELECT
    'dim_tempo' AS tabela,
    COUNT(*) AS total_registros
FROM workspace.sinal_cidadao.dim_tempo

UNION ALL

SELECT
    'fato_clima' AS tabela,
    COUNT(*) AS total_registros
FROM workspace.sinal_cidadao.fato_clima;
