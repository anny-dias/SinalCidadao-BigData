import hashlib
import json
import logging
from datetime import datetime, timedelta, timezone
from pathlib import Path
from urllib.parse import urlencode
from urllib.request import Request, urlopen

from airflow.sdk import dag, task, get_current_context


PROJETO = Path.home() / "SinalCidadao-BigData"
CHEGADA = PROJETO / "chegada"

LOG = logging.getLogger(__name__)


def consultar_api(url, parametros=None):
    if parametros:
        url = f"{url}?{urlencode(parametros)}"

    requisicao = Request(
        url,
        headers={"User-Agent": "SinalCidadao-BigData/1.0"}
    )

    with urlopen(requisicao, timeout=40) as resposta:
        return json.load(resposta)


def salvar_coleta(fonte, dados):
    contexto = get_current_context()

    identificador = hashlib.sha256(
        contexto["run_id"].encode("utf-8")
    ).hexdigest()[:12]

    agora = datetime.now(timezone.utc)

    pasta = CHEGADA / fonte
    pasta.mkdir(parents=True, exist_ok=True)

    arquivo = pasta / (
        f"{fonte}_{agora:%Y-%m-%d}_{identificador}.json"
    )

    conteudo = {
        "fonte": fonte,
        "coletado_em": agora.isoformat(),
        "identificador_execucao": identificador,
        "dados": dados,
    }

    temporario = arquivo.with_suffix(".tmp")

    try:
        with temporario.open("w", encoding="utf-8") as f:
            json.dump(conteudo, f, ensure_ascii=False)

        temporario.replace(arquivo)

    finally:
        temporario.unlink(missing_ok=True)

    LOG.info("Arquivo salvo: %s", arquivo)

    return str(arquivo)


@dag(
    dag_id="gs_sinal_cidadao_coleta",
    description="Coleta de dados públicos para o Sinal Cidadão",
    schedule="@daily",
    start_date=datetime(2026, 11, 17, tzinfo=timezone.utc),
    catchup=False,
    max_active_runs=1,
    tags=["sinal-cidadao", "big-data", "citizentech"],
)
def pipeline_sinal_cidadao():

    @task(retries=2, retry_delay=timedelta(minutes=2))
    def coletar_clima():

        dados = consultar_api(
            "https://api.open-meteo.com/v1/forecast",
            {
                "latitude": -23.55,
                "longitude": -46.63,
                "hourly": "temperature_2m,precipitation",
                "forecast_days": 2,
                "timezone": "America/Sao_Paulo",
            },
        )

        if not dados.get("hourly", {}).get("time"):
            raise ValueError(
                "Open-Meteo retornou dados horários inválidos"
            )

        LOG.info(
            "Coleta climática realizada: %s horários",
            len(dados["hourly"]["time"])
        )

        return salvar_coleta("clima", dados)

    @task(retries=2, retry_delay=timedelta(minutes=2))
    def coletar_municipios():

        dados = consultar_api(
            "https://servicodados.ibge.gov.br/api/v1/localidades/municipios"
        )

        if not isinstance(dados, list) or not dados:
            raise ValueError(
                "IBGE retornou uma lista de municípios inválida"
            )

        LOG.info(
            "Coleta municipal realizada: %s municípios",
            len(dados)
        )

        return salvar_coleta("municipios", dados)

    @task
    def validar_arquivos(arquivo_clima, arquivo_municipios):

        arquivos = [arquivo_clima, arquivo_municipios]

        for caminho in arquivos:
            arquivo = Path(caminho)

            if not arquivo.is_file():
                raise FileNotFoundError(
                    f"Arquivo não encontrado: {arquivo}"
                )

            with arquivo.open(encoding="utf-8") as f:
                conteudo = json.load(f)

            if not conteudo.get("dados"):
                raise ValueError(
                    f"Arquivo sem dados válidos: {arquivo}"
                )

            LOG.info(
                "Arquivo validado: %s (%s bytes)",
                arquivo.name,
                arquivo.stat().st_size
            )

        LOG.info("Coleta concluída: 2 arquivos validados")

        return {
            "status": "sucesso",
            "arquivos_validados": len(arquivos),
        }

    clima = coletar_clima()
    municipios = coletar_municipios()

    validar_arquivos(clima, municipios)


pipeline_sinal_cidadao()
