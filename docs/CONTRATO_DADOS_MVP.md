# Sinal Cidadão — Contrato de dados com o MVP e conformidade LGPD

## 1. Problema e contribuição desta entrega

O Sinal Cidadão propõe semáforos adaptativos com foco na segurança de pedestres e na mobilidade urbana. O **componente de dados implementado nesta entrega** disponibiliza informações públicas de contexto territorial e meteorológico que podem subsidiar futuras regras operacionais. Não há, nesta versão, medição direta de veículos ou pedestres nem comando automático de semáforos.

### Por que dados climáticos importam para o produto?

- **Previsão de chuva:** sinaliza situações em que a travessia pode requerer atenção adicional de operadores e da população.
- **Precipitação prevista por horário:** permite identificar períodos de possível adversidade climática e exibir avisos contextuais.
- **Dimensão temporal:** associa condições climáticas à hora de referência, permitindo análises diárias.
- **Municípios do IBGE:** fornecem referência territorial padronizada para expansão posterior do serviço.

O clima **não prova** redução de congestionamento, segurança ou tempo de espera. Esses impactos exigem telemetria dos cruzamentos e comparação experimental entre estratégias semafóricas.

## 2. Contrato entre a camada Ouro e o dashboard

| Origem na Ouro | Campos / operação | Indicador exibido | Interpretação e limite |
| --- | --- | --- | --- |
| `workspace.sinal_cidadao.dim_municipio` | `COUNT(*)` | Municípios cadastrados | Cobertura cadastral IBGE; não representa cruzamentos instrumentados. |
| `workspace.sinal_cidadao.fato_clima` | `COUNT(*)` | Horários de previsão analisados | Quantidade de horários com registros na fato. |
| `workspace.sinal_cidadao.fato_clima` | `AVG(temperatura_c)` | Temperatura média prevista | Previsão em °C para a localização de referência. |
| `workspace.sinal_cidadao.fato_clima` | `SUM(precipitacao_mm)` | Precipitação prevista | Acumulado de previsão em mm; não é medição observada. |
| `workspace.sinal_cidadao.fato_clima` | `SUM(indicador_chuva)` | Horários com previsão de chuva | Total de horários com precipitação prevista maior que zero. |

**Localização da demonstração:** dashboard `Sinal Cidadão | Inteligência de Dados Urbanos`, com captura em `evidencias/dashboard_final_72_horarios.png`. As dimensões `dim_tempo` e `dim_municipio` permitem organizar consultas por horário e município, mas o modelo de fato atualmente associa as previsões à referência de São Paulo (código IBGE `3550308`).

**Valores observados após o segundo lote:** 5.571 municípios cadastrados, 72 horários analisados, 18,3 mm de precipitação prevista e 16 horários com previsão de chuva. Esses valores correspondem às evidências apresentadas, não a leituras ao vivo.

## 3. Consulta de impacto potencial — interpretação correta

A quinta consulta SQL (`databricks/10_consultas_mvp.sql`) calcula a proporção de horários com previsão de precipitação.

Com os totais observados no segundo lote: `16 / 72 × 100 = 22,22%`.

**Interpretação:** cerca de 22,22% dos horários analisados tinham previsão de alguma chuva no conjunto de dados coletado. Esse resultado **não é** probabilidade de chuva nem impacto medido em trânsito, tempo semafórico, colisões ou emissões.

### Indicadores de impacto que exigem integração futura

1. Tempo médio de espera do pedestre antes/depois da estratégia adaptativa.
2. Quantidade de veículos parados por ciclo semafórico.
3. Tempo médio de travessia em condições normais e com chuva.
4. Fluxo de veículos e pedestres coletado de forma anonimizada por sensores ou simulação.

Esses indicadores **não foram implementados no pipeline Big Data apresentado** e não devem ser declarados como resultados obtidos.

## 4. LGPD e segurança

As fontes efetivamente utilizadas, IBGE Localidades e Open-Meteo Forecast, fornecem dados de municípios, coordenadas geográficas, horários e variáveis meteorológicas, sem identificação individual de cidadãos.

- A camada Ouro não inclui nomes de pedestres, CPF, placas, imagens faciais ou identificadores de dispositivos pessoais.
- Não se aplica hash ou máscara de identificação pessoal inexistente nessa base.
- Caso imagens e sensores sejam adicionados, recomenda-se processamento local na borda com publicação apenas de contagens agregadas e avaliação específica de base legal, minimização, retenção e controles de acesso.
- Credenciais e arquivos locais de execução ficam fora do repositório por meio do `.gitignore` e das práticas de configuração do ambiente.

## 5. Limite da integração e próximos passos

O contrato **implementado e demonstrado** é `Databricks Ouro → consultas SQL → dashboard analítico`. Não foi demonstrada ligação operacional `dashboard → controlador de semáforos` nem ingestão de telemetria de tráfego. O próximo estágio do produto pode correlacionar o contexto meteorológico da Ouro com indicadores reais ou simulados de mobilidade, mantendo a separação entre dados previstos e medições observadas.
