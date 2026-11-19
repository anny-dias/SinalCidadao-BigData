-- Criar a tabela definitiva de municípios

CREATE TABLE IF NOT EXISTS workspace.sinal_cidadao.prata_municipios (
    codigo_ibge BIGINT,
    nome_municipio STRING,
    data_coleta TIMESTAMP
)
USING DELTA;
-- Inserir novos municípios e atualizar os existentes

MERGE INTO workspace.sinal_cidadao.prata_municipios AS destino

USING (
    SELECT
        codigo_ibge,
        nome_municipio,
        data_coleta
    FROM (
        SELECT
            TRY_CAST(municipio.id AS BIGINT) AS codigo_ibge,
            TRIM(municipio.nome) AS nome_municipio,
            TRY_CAST(coletado_em AS TIMESTAMP) AS data_coleta,

            ROW_NUMBER() OVER (
                PARTITION BY municipio.id
                ORDER BY coletado_em DESC
            ) AS numero_linha

        FROM workspace.sinal_cidadao.bronze_municipios

        LATERAL VIEW EXPLODE(dados) AS municipio
    )

    WHERE numero_linha = 1
      AND codigo_ibge IS NOT NULL
      AND LENGTH(CAST(codigo_ibge AS STRING)) = 7
      AND nome_municipio IS NOT NULL
      AND nome_municipio <> ''
      AND data_coleta IS NOT NULL
) AS origem

ON destino.codigo_ibge = origem.codigo_ibge

WHEN MATCHED AND origem.data_coleta >= destino.data_coleta THEN
    UPDATE SET
        destino.nome_municipio = origem.nome_municipio,
        destino.data_coleta = origem.data_coleta

WHEN NOT MATCHED THEN
    INSERT (
        codigo_ibge,
        nome_municipio,
        data_coleta
    )
    VALUES (
        origem.codigo_ibge,
        origem.nome_municipio,
        origem.data_coleta
    );

    SELECT COUNT(*) AS total_municipios
FROM workspace.sinal_cidadao.prata_municipios;
SELECT *
FROM workspace.sinal_cidadao.prata_municipios
ORDER BY nome_municipio
LIMIT 10;
SELECT
    codigo_ibge,
    COUNT(*) AS quantidade
FROM workspace.sinal_cidadao.prata_municipios
GROUP BY codigo_ibge
HAVING COUNT(*) > 1;
-- Inserir novos municípios e atualizar os existentes


WHEN MATCHED AND origem.data_coleta >= destino.data_coleta THEN
    UPDATE SET
        destino.nome_municipio = origem.nome_municipio,
        destino.data_coleta = origem.data_coleta

WHEN NOT MATCHED THEN
    INSERT (
        codigo_ibge,
        nome_municipio,
        data_coleta
    )
    VALUES (
        origem.codigo_ibge,
        origem.nome_municipio,
        origem.data_coleta
        
    );

    SELECT COUNT(*) AS total_municipios
FROM workspace.sinal_cidadao.prata_municipios;
