# Guia de execução — Sinal Cidadão Big Data

## 1. Preparação

O projeto utiliza:

- Apache Airflow 3
- Python
- Databricks Free Edition
- Delta Lake
- Databricks SQL

O Airflow e o Databricks são utilizados separadamente.

Na versão acadêmica, os arquivos coletados são enviados
manualmente ao Volume do Databricks.

## 2. Coleta no Airflow

Ativar o ambiente Python:

```bash
cd ~/SinalCidadao-BigData
source .venv/bin/activate
export AIRFLOW_HOME="$PWD/.airflow"
```

Iniciar o Airflow:

```bash
airflow standalone
```

Acessar:

http://localhost:8080

Executar a DAG:

`gs_sinal_cidadao_coleta`

Verificar o sucesso das tarefas:

1. coletar_clima
2. coletar_municipios
3. validar_arquivos

As tarefas de coleta são executadas em paralelo.

## 3. Preparação no Databricks

Criar o schema:

`workspace.sinal_cidadao`

Criar o Volume:

`/Volumes/workspace/sinal_cidadao/chegada`

Criar os diretórios:

- clima
- municipios

Enviar os arquivos JSON produzidos pelo Airflow.

## 4. Primeira ingestão

Executar:

`databricks/01_bronze.sql`

Confirmar os registros carregados.

Executar novamente o COPY INTO para verificar que os
mesmos arquivos não são inseridos duas vezes.

## 5. Processamento da Prata

Executar na sequência:

1. 02_prata_municipios_qualidade.sql
2. 03_prata_municipios_merge.sql
3. 04_prata_clima.sql
4. 05_qualidade_clima.sql
5. 06_prata_clima_merge.sql

O arquivo 04 cria a view persistente:

`workspace.sinal_cidadao.vw_candidatos_clima`

Essa view é necessária para os arquivos 05 e 06.

## 6. Criação da Ouro

Na primeira execução, utilizar:

1. 07_ouro_dimensoes.sql
2. 09_atualizar_dimensao_tempo.sql
3. 08_ouro_fato_clima.sql

A dimensão de tempo deve ser atualizada antes da
reconstrução da tabela fato.

## 7. Consultas do MVP

Executar:

`10_consultas_mvp.sql`

O arquivo contém cinco consultas SQL relacionadas
às informações disponíveis na camada Ouro.

## 8. Segundo lote e idempotência

Realizar nova coleta em outra data.

Enviar os arquivos novos ao Volume.

Antes da ingestão, executar:

`11_bronze_antes_segundo_lote.sql`

Em seguida:

`12_bronze_segundo_lote_idempotencia.sql`

Executar o COPY INTO novamente para comprovar que
não ocorre duplicação dos arquivos já processados.

## 9. Atualização após o segundo lote

Executar:

1. 03_prata_municipios_merge.sql
2. 06_prata_clima_merge.sql
3. 09_atualizar_dimensao_tempo.sql
4. 08_ouro_fato_clima.sql

## 10. Validação final

Executar:

- 13_validacao_prata.sql
- 14_validacao_ouro.sql

Resultados observados na implementação:

| Camada | Tabela | Registros |
|---|---|---:|
| Bronze | bronze_clima | 2 |
| Bronze | bronze_municipios | 2 |
| Prata | prata_municipios | 5571 |
| Prata | prata_clima | 72 |
| Ouro | dim_municipio | 5571 |
| Ouro | dim_tempo | 72 |
| Ouro | fato_clima | 72 |

Os valores correspondem aos lotes utilizados na
demonstração, não a quantidades fixas do sistema.

## 11. Dashboard

O dashboard consulta:

`workspace.sinal_cidadao.fato_clima`

Os indicadores devem ser atualizados após a
execução das camadas Prata e Ouro.

## 12. Segurança

Não publicar senhas, tokens, arquivos internos do
Airflow ou credenciais do Databricks.

Não utilizar dados pessoais reais nas evidências.

As informações utilizadas nesta implementação são
provenientes de APIs públicas.
