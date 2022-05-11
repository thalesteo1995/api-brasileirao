"""
    Description:
        Realiza Webscraping no site da CBF para obter informações
        do desempenho dos times que disputaram o campeoato brasileiro dos
        últimos anos.

    Author:           @Thales
    Created:          2022-05-08
"""
import sys
import logging
import requests
import re
import json

from pathlib import Path
from dynaconf import Dynaconf
from tqdm import tqdm
from bs4 import BeautifulSoup

settings = Dynaconf(
    envvar_prefix="BRASILEIRO",
    settings_files=["settings.toml"],
    environments=True,
    load_dotenv=True,
)


def main():
    """_summary_"""

    Path("logs").mkdir(exist_ok=True, parents=True)
    logging.basicConfig(
        filename=f"logs/{settings.LOG_MONITOR}", filemode="w", level=logging.DEBUG
    )
    lst_dicts = []
    pbar_convert = tqdm(total=settings.ANO_FINAL - settings.ANO_INICIAL + 1)
    for ano in range(settings.ANO_INICIAL, settings.ANO_FINAL + 1):
        url_cbf = f"{settings.BASE_URL_CBF}/{ano}"
        try:
            soup = BeautifulSoup(requests.get(url_cbf).text, features="html.parser")
        except requests.exceptions.ConnectionError as err:
            logging.error(err)
            logging.error("Erro de Conexão com  Internet!")
            sys.exit()

        for id_clube_tabela in range(0, 20):
            clube = soup.find_all(class_="expand-trigger")[id_clube_tabela].get_text()
            string_clube = re.sub(r"\n", "/", clube)
            lst_info_clube = string_clube.split("/")
            nome_clube = lst_info_clube[6]
            num_pontos = lst_info_clube[8]
            num_vitorias = lst_info_clube[10]
            num_empates = lst_info_clube[11]
            num_derrotas = lst_info_clube[12]
            gols_pro = lst_info_clube[13]
            gols_contra = lst_info_clube[14]

            data = {
                    nome_clube: {
                        "brasileirao": ano,
                        "pontos": num_pontos,
                        "vitorias": num_vitorias,
                        "empates": num_empates,
                        "derrotas": num_derrotas,
                        "gols_pro": gols_pro,
                        "gols_contra": gols_contra,
                }
            }

            lst_dicts.append(data)
            logging.info(f"Brasileirao {ano} - Finalizado!")

        pbar_convert.update(1)
    pbar_convert.close()

    with open(Path(settings.DIR_OUTPUT)/settings.ARQUIVO_JSON, "w", encoding="UTF-8") as f:
        json.dump(lst_dicts, f)

    logging.info(f"ARQUIVO {settings.ARQUIVO_JSON} CRIADO!!!")
    print(f"ARQUIVO {settings.ARQUIVO_JSON} CRIADO!!!")
