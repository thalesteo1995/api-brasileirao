"""
    Description:

    api-brasileirao

    Author:           @Thales
    Created:          2022-05-08
"""

from dynaconf import Dynaconf
from setups.s01_webscraping_cbf import main as s01_webscraping_cbf

settings = Dynaconf(
    envvar_prefix="BRASILEIRO",
    settings_files=["settings.toml"],
    environments=True,
    load_dotenv=True,
)


def main():
    """_summary_"""

    # s01
    if settings.S01:
        s01_webscraping_cbf()


if __name__ == "__main__":
    main()
