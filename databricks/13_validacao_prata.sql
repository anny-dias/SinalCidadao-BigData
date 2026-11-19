-- Conferência da camada Prata após o segundo lote

SELECT
    'Municípios' AS tabela,
    COUNT(*) AS total_registros
FROM workspace.sinal_cidadao.prata_municipios

UNION ALL

SELECT
    'Clima' AS tabela,
    COUNT(*) AS total_registros
FROM workspace.sinal_cidadao.prata_clima;

-- Verificar códigos de municípios duplicados

-- Verificar códigos de municípios duplicados

SELECT
    COUNT(*) AS municipios_duplicados
FROM (
    SELECT codigo_ibge
    FROM workspace.sinal_cidadao.prata_municipios
    GROUP BY codigo_ibge
    HAVING COUNT(*) > 1
);
);
