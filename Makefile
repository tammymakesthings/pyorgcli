#############################################################################
# cookiecutter-pyproject Makefile
#############################################################################

PROJECT_DIR := $(dir $(PWD))
PROJECT_SLUG := pyorgcli

TEST_DIR := $(PROJECT_DIR)/tests
SOURCE_DIR := $(PROJECT_DIR)/$(PROJECT_SLUG)

TEST_FILES := $(shell find "$(TEST_DIR)" -name '*.py' -print)
SOURCE_FILES := $(shell find "$(SOURCE_DIR)" -name '*.py' -print)
BASEDIR_FILES := $(wildcard $(PROJECT_DIR)/*.py)

BAKE_OPTIONS := --no-input
PYTEST_OPTIONS := --verbose \
				  --color=auto \
				  --code-highlight=yes \
				  --junit-xml=$(PROJECT_FOLDER)/junit.xml \
				  --doctest-modules \
				  --doctest-continue-on-failures
AUTOPEP8_OPTIONS := --in-place \
					--recursive
FLAKE8_OPTIONS := --format pylint \
				  --statistics \
				  --doctests
MYPY_OPTIONS := --namespace-packages \
				--python-version 3.9 \
				--show-error-context --pretty \
				--color-output \
				--html-report $(PWD)/mypy-html \
				--junit-xml $(PWD)/junit.xml
YAPF_OPTIONS := --in-place \
				--style pep8 \
				--parallel
BLACK_OPTIONS := --color
TOX_OPTIONS := --parallel \
			   --recreate

help:
	@echo "bake 	   generate project using defaults"
	@echo "watch 	   generate project using defaults and watch for changes"
	@echo "replay 	   replay last cookiecutter run and watch for changes"
	@echo "pytest      run pytest            (unit tests)"
	@echo "autopep8    run autopep8          (code style checker)"
	@echo "flake8      run flake8            (code style checker)"
	@echo "mypy        run mypy              (type checking)"
	@echo "yapf        run yapf              (code formatting)"
	@echo "black       run black             (code formatting)"
	@echo "tox         run tox               (multi-version testing)"
	@echo "install     run pipenv install    (install modules)"
	@echo "shell       open a pipenv shell"

bake:
	cookiecutter $(BAKE_OPTIONS) . --overwrite-if-exists

watch: bake
	watchmedo shell-command -p '*.*' -c 'make bake -e BAKE_OPTIONS=$(BAKE_OPTIONS)' -W -R -D \pyorgcli/

pytest:
	pipenv run pytest $(PYTEST_OPTIONS) $(TEST_DIR)

test : pytest

.PHONY: pytest test

autopep8:
	pipenv run autopep8 $(AUTOPEP8_OPTIONS) \
		$(SOURCE_DIR) \
		$(TEST_DIR) \
		$(BASEDIR_FILES)

.PHONY: autopep8

flake8:
	pipenv run flake8 $(FLAKE8_OPTIONS) \
		$(SOURCE_DIR) \
		$(TEST_DIR) \
		$(BASEDIR_FILES)

.PHONY: flake8

mypy:
	pipenv run mypy $(MYPY_OPTIONS) \
		$(SOURCE_DIR) \
		$(TEST_DIR) \
		$(BASEDIR_FILES)

.PHONY: mypy

yapf:
	pipenv run yapf $(YAPF_OPTIONS) \
		$(SOURCE_DIR) \
		$(TEST_DIR) \
		$(BASEDIR_FILES)

.PHONY: yapf

black:
	pipenv run black $(BLACK_OPTIONS) \
		$(SOURCE_DIR) \
		$(TEST_DIR) \
		$(BASEDIR_FILES)

.PHONY: black

tox:
	pipenv run tox

install:
	pipenv --dev install

shell:
	pipenv shell

replay: BAKE_OPTIONS=--replay
replay: watch

.PHONY: tox install shell
.PHONY: help
