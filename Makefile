path := .

.PHONY: help
help: ## Show this help message
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'


.PHONY: lint
lint: black isort flake mypy	## Apply all the linters


.PHONY: lint-check
lint-check: ## Aplica a limpeza geral
	@echo
	@echo "Checking linter rules..."
	@echo "========================"
	@echo
	@black --check $(path)
	@isort --check $(path)
	@flake8 $(path)
	@mypy $(path)


.PHONY: black
black: ## Apply black
	@echo
	@echo "Applying black..."
	@echo "================="
	@echo
	@ # --fast was added to circumnavigate a black bug
	@black --fast $(path)
	@echo


.PHONY: isort
isort: ## Apply isort
	@echo "Applying isort..."
	@echo "================="
	@echo
	@isort $(path)


.PHONY: flake
flake: ## Apply flake8
	@echo
	@echo "Applying flake8..."
	@echo "================="
	@echo
	@flake8 $(path)


.PHONY: mypy
mypy: ## Apply mypy
	@echo
	@echo "Applying mypy..."
	@echo "================="
	@echo
	@mypy $(path)


.PHONY: trim-imports
trim-imports: ## Remove unused imports
	@autoflake --remove-all-unused-imports \
	--ignore-init-module-imports \
	--in-place \
	--recursive \
	$(path)


.PHONY: dep-lock
dep-lock: ## Freeze deps in `requirements.txt` file
	@sort --ignore-case -o requirements.in requirements.in
	@pip-compile requirements.in --output-file=requirements.txt


.PHONY: dep-sync
dep-sync: ## Sync venv installation with `requirements.txt`
	@pip-sync


SHELL := /usr/bin/env bash
PY?=python3
WORKDIR?=.
VENVDIR?=$(WORKDIR)/.venv
REQUIREMENTS_TXT?=requirements.txt  # Multiple paths are supported (space separated)
MARKER=.inicializado-pelo-Makefile.venv
PROJECTNAME := $(shell basename $(CURDIR))
DIR:=$(strip $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST)))))

#
# Internal variable resolution
#

VENV=$(VENVDIR)/bin
EXE=
# Detect windows
ifeq (win32,$(shell $(PY) -c "import __future__, sys; print(sys.platform)"))
VENV=$(VENVDIR)/Scripts
EXE=.exe
endif


.PHONY: venv
venv: $(VENV)/$(MARKER)


.PHONY: clean
clean: ## Remove os dirs: Saida, logs, __pycache__
	@find . -name '*.pyc' -delete
	@find . -name '__pycache__' -delete
	@rm -rf ./Saida
	@rm -rf ./logs
	@find . -type f -wholename './Saida/*.json' -delete
	@find . -type f -wholename './logs/*.log' -delete

.PHONY: clean-venv
clean-venv: ## Remove o diretorio .venv
	@-$(RM) -r "$(VENVDIR)"

.PHONY: show-venv
show-venv: ## Mostra informações do diretorio .venv
	@venv
	@$(VENV)/python -c "import sys; print('Python ' + sys.version.replace('\n',''))"
	@$(VENV)/pip --version
	@echo venv: $(VENVDIR)

.PHONY: debug-venv
debug-venv: ## Mostra versões informações do diretorio .venv
	@$(MAKE) --version
	$(info PY="$(PY)")
	$(info REQUIREMENTS_TXT="$(REQUIREMENTS_TXT)")
	$(info VENVDIR="$(VENVDIR)")
	$(info WORKDIR="$(WORKDIR)")


#
# Dependencies
# Ref: https://github.com/mnot/redbot/blob/main/Makefile.venv
#

_REQUIREMENTS=$(strip $(foreach path, $(REQUIREMENTS_TXT), $(wildcard $(path))))
ifneq ($(_REQUIREMENTS),)
VENVDEPENDS+=$(_REQUIREMENTS)
endif


$(VENV):
	$(PY) -m venv $(VENVDIR)
	$(VENV)/python -m pip install --upgrade pip setuptools

$(VENV)/$(MARKER): $(VENVDEPENDS) | $(VENV)
ifneq ($(_REQUIREMENTS),)
	$(VENV)/pip install $(foreach path,$(_REQUIREMENTS),-r $(path))
endif


#
# Interactive shells
# Ref: https://github.com/mnot/redbot/blob/main/Makefile.venv
#

.PHONY: python
python: venv
	exec $(VENV)/python

.PHONY: ipython
ipython: $(VENV)/ipython
	exec $(VENV)/ipython

.PHONY: update
update: venv # active venv
	$(VENV)/pip freeze > requirements.txt


.PHONY: install
install: venv
	@. $(VENV)/activate && exec $(notdir $(SHELL))
	@pre-commit install
	@pre-commit autoupdate


ifneq ($(EXE),)
$(VENV)/%: $(VENV)/%$(EXE) ;
.PHONY:    $(VENV)/%
.PRECIOUS: $(VENV)/%$(EXE)
endif

$(VENV)/%$(EXE): $(VENV)/$(MARKER)
	$(VENV)/pip install --upgrade $*
	touch $@
