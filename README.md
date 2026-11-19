# Sinal Cidadão — Big Data Architecture & Data Integration

Global Solution 2026.2 — FIAP  
Engenharia de Software — 4º ano

## 1. Sobre o projeto

O Sinal Cidadão é uma proposta de sistema de semáforos adaptativos
voltada à mobilidade urbana, à segurança de pedestres e à melhoria
da gestão de cruzamentos.

O MVP propõe utilizar câmeras, inteligência artificial na borda
e regras de decisão para adaptar o tempo dos semáforos conforme
a demanda de veículos e pedestres.

Este repositório contém exclusivamente o componente de Big Data
da Global Solution, independente da entrega de RPA.

O pipeline desenvolvido coleta dados públicos, realiza
processamento nas camadas Bronze, Prata e Ouro e disponibiliza
indicadores em um dashboard.

## 2. Integrantes

- Anny Dias — RM 98295
- Henrique Lima — RM 551528
- Pedro Henrique Menezes — RM 97432

## 3. Objetivo

Construir um pipeline de dados que permita coletar, organizar,
validar e disponibilizar informações externas para apoiar
análises relacionadas ao planejamento urbano.

Nesta implementação, utilizamos dados meteorológicos e
informações oficiais dos municípios brasileiros.

As informações climáticas permitem contextualizar condições
ambientais que podem influenciar a mobilidade e o planejamento
operacional de cruzamentos.

Os dados não representam medições reais de congestionamentos,
tempo de espera, emissões ou acidentes.

## 4. Tecnologias utilizadas

| Tecnologia | Finalidade |
|---|---|
| Python | Coleta e validação dos dados |
| Apache Airflow 3 | Orquestração e agendamento |
| Open-Meteo | Previsões meteorológicas |
| API do IBGE | Informações oficiais dos municípios |
| Databricks Free Edition | Processamento dos dados |
| Delta Lake | Armazenamento das tabelas |
| Databricks SQL | Transformações e consultas |
| Databricks AI/BI Dashboard | Visualização dos indicadores |
| GitHub | Versionamento e disponibilização |

## 5. Arquitetura

O pipeline segue o fluxo:

1. APIs públicas Open-Meteo e IBGE.
2. DAG agendada no Apache Airflow.
3. Coleta paralela das duas fontes.
4. Validação dos arquivos recebidos.
5. Gravação dos arquivos JSON em `chegada/`.
6. Upload manual para o Volume do Databricks.
7. Ingestão incremental na Bronze com `COPY INTO`.
8. Tratamento e MERGE na Prata.
9. Modelo dimensional na Ouro.
10. Consultas SQL e dashboard de indicadores.

O upload manual entre Airflow e Databricks é uma característica
da implementação acadêmica utilizando o Databricks Free Edition.

## 6. Fontes de dados

### Open-Meteo

- Origem: API pública Open-Meteo.
- Formato: JSON.
- Dados: previsão horária de temperatura e precipitação.
- Localidade analisada: São Paulo.
- Frequência planejada: diária.

### IBGE

- Origem: API pública de localidades do IBGE.
- Formato: JSON.
- Dados: códigos e nomes dos municípios brasileiros.
- Frequência planejada: diária.

## 7. Organização do repositório

- `dags/`: código Python da DAG do Airflow.
- `databricks/`: scripts SQL das camadas Bronze, Prata e Ouro.
- `amostras/`: exemplos das respostas das fontes públicas.
- `evidencias/`: capturas de tela das execuções e validações.
- `docs/`: documentação técnica complementar.
- `README.md`: instruções e visão geral do projeto.

Os arquivos operacionais de `chegada/`, o ambiente virtual Python
e o banco interno do Airflow não são publicados.

## 8. Execução do Airflow

Ambiente utilizado: Ubuntu no WSL2, com Python e Apache Airflow 3.

### Preparar o terminal

```bash
cd ~/SinalCidadao-BigData
source .venv/bin/activate
export AIRFLOW_HOME="$PWD/.airflow"
```

### Verificar a instalação

```bash
airflow version
```

### Iniciar o Airflow

```bash
airflow standalone
```

Acessar:

http://localhost:8080

A DAG utilizada é:

`gs_sinal_cidadao_coleta`

Para reproduzir a coleta, iniciar a DAG e acompanhar
as tarefas de coleta climática, coleta de municípios e
validação dos arquivos.

A configuração do Airflow deve apontar para a pasta
`dags/` deste repositório.

## 9. Databricks

Catalog:

`workspace`

Schema:

`sinal_cidadao`

Volume:

`/Volumes/workspace/sinal_cidadao/chegada`

Os arquivos JSON são enviados manualmente às pastas
`clima/` e `municipios/` do Volume.

### Camada Bronze

O carregamento utiliza `COPY INTO`.

Arquivos já processados não são carregados novamente
nas reexecuções normais, preservando a idempotência.

### Camada Prata

A camada Prata aplica:

- Conversão de tipos.
- Tratamento de valores nulos.
- Validação de códigos de municípios.
- Validação de temperatura e precipitação.
- Remoção lógica de duplicações por chave.
- MERGE para inserção e atualização.

### Camada Ouro

O modelo dimensional contém:

- `dim_municipio`
- `dim_tempo`
- `fato_clima`

A tabela fato possui informações climáticas associadas
ao município de São Paulo e aos horários de referência.

## 10. Resultados verificados

### Bronze

| Etapa | Clima | Municípios |
|---|---:|---:|
| Primeiro lote | 1 | 1 |
| Segundo lote | 2 | 2 |
| Reexecução do COPY INTO | 2 | 2 |

As contagens representam documentos JSON carregados,
não o total de registros internos de cada documento.

### Prata

- Municípios tratados: 5.571.
- Registros climáticos únicos: 72.
- Municípios duplicados: 0.
- Horários climáticos duplicados: 0.

### Ouro

| Tabela | Registros |
|---|---:|
| dim_municipio | 5.571 |
| dim_tempo | 72 |
| fato_clima | 72 |

## 11. Consultas SQL

Foram desenvolvidas cinco consultas relacionadas a:

1. Quantidade de municípios.
2. Temperaturas previstas.
3. Precipitação prevista.
4. Horários e condições climáticas.
5. Indicadores de exposição climática.

A quinta consulta representa um indicador de contexto
ambiental, não uma medição direta de redução de filas,
CO2 ou tempo de espera.

Os códigos estão disponíveis na pasta `databricks/`.

## 12. Dashboard e contrato com o MVP

O dashboard "Sinal Cidadão | Inteligência de Dados Urbanos"
consulta a camada Ouro, especialmente a tabela:

`workspace.sinal_cidadao.fato_clima`

Também utiliza a dimensão municipal para apresentar
a cobertura dos dados de localidades.

Os indicadores apresentados incluem:

- Municípios cadastrados.
- Horários de previsão analisados.
- Temperatura média prevista.
- Precipitação prevista.
- Horários com previsão de chuva.

A integração demonstrada nesta entrega é a disponibilização
dos dados da Ouro ao dashboard analítico.

A conexão direta com o controlador adaptativo de semáforos
não foi implementada neste componente.

## 13. LGPD e segurança

O pipeline utiliza fontes públicas e indicadores agregados.

Não são coletados rostos, placas de veículos, nomes de
pedestres, documentos pessoais ou dados de identificação
individual.

A camada Ouro não armazena dados pessoais dos cidadãos.

No MVP proposto, imagens de câmeras deverão ser processadas
na borda, disponibilizando somente contagens anônimas.

Credenciais, senhas e arquivos internos de execução não
devem ser publicados no GitHub.

## 14. Limitações

Os dados meteorológicos são previsões de uma API externa.
Não representam medições realizadas pelo semáforo.

A implementação acadêmica não controla equipamentos
semafóricos reais.

A redução de congestionamentos, emissões e espera é um
benefício esperado da proposta Sinal Cidadão, que dependerá
de testes operacionais específicos para ser comprovado.

## 15. Evidências

A pasta `evidencias/` contém capturas de tela de:

- Execuções do Airflow.
- Arquivos enviados ao Volume.
- Ingestão incremental na Bronze.
- Testes de idempotência.
- Regras de qualidade da Prata.
- MERGE e ausência de duplicações.
- Modelo dimensional da Ouro.
- Consultas SQL.
- Dashboard com dados atualizados.

## 16. Repositório e entrega

Disciplina: Big Data Architecture & Data Integration.

Global Solution 2026.2 — CitizenTech.

Os scripts, as amostras e as evidências deste repositório
compõem a entrega acadêmica do componente de dados.
