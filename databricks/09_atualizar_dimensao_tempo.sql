-- =====================================================
-- SINAL CIDADÃO - ATUALIZAR DIMENSÃO DE TEMPO
-- =====================================================

MERGE INTO workspace.sinal_cidadao.dim_tempo AS destino

USING (
    SELECT DISTINCT
        data_hora,
        CAST(data_hora AS DATE) AS data_referencia,
        HOUR(data_hora) AS hora

    FROM workspace.sinal_cidadao.prata_clima

    WHERE data_hora IS NOT NULL
) AS origem

ON destino.data_hora = origem.data_hora

WHEN NOT MATCHED THEN
    INSERT (
        data_hora,
        data_referencia,
        hora
    )
    VALUES (
        origem.data_hora,
        origem.data_referencia,
        origem.hora
    );


-- Conferir quantidade de horários

SELECT
    COUNT(*) AS total_horarios
FROM workspace.sinal_cidadao.dim_tempo;
