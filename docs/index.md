# Api Braisleirao

!!! note "Objetivo do Projeto"
    Construir uma api com informações do desempenhos dos times
    que disputaram o campeonato brasileiro dos últimos anos.

Essas informações foram extraídas do site da <a href="https://www.cbf.com.br/futebol-brasileiro/competicoes/campeonato-brasileiro-serie-a" target="_blank">CBF</a> utilizando Webscraping.

!!! note "Como executar o projeto?"
  * `poetry shell` - Cria e ativa ambiente virtual (.venv);
  * `poetry install` - Instala todos requisitos python do projeto;
  * `python main.py` - Constroi o db.json que é salvo no diretório output

  `O log do que é executado no main.py fica salvo no diretório logs.`

!!! tip "Dica para publicação de API"
- Uma forma de expor os dados na internet de forma rápida e fácil utilizar o <a href="https://www.npmjs.com/package/json-server" target="_blank">json-server</a> combinado com <a href="https://ngrok.com/" target="_blank">ngrok</a>.
- Com essas duas ferramentas instaladas na máquina local, basta executar:

    - [x] `json-server --watch db.json` (cria a api no http://localhost:3000)
    - [x] `ngrok http 3000` (cria um túnel na porta 3000 expondo esse servidor web)
