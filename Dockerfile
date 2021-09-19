# syntax=docker/dockerfile:1

# 1. Base image
FROM python:3.9.7-slim-buster AS builder

ARG SPINUP_ENV=PROD     # docker build --build-arg=DEV to build a dev VM
ENV SPINUP_ENV

ARG APTGET_OPTS="--yes --no-install-recommends -y"       # apt-get flags
ENV APTGET_OPTS

# Install the minimal stuff for python
RUN apt-get update && \
    apt-get install $APTGET_OPTS python3-venv gcc libpython3-dev

# For dev boxes install some additional stuff
RUN if [ "x$SPINUP_ENV" = "xDEV" ]; then apt-get install $APTGET_OPTS build-essential git pandoc vim-nox; fi

# Update and setup pip
RUN python -m pip install --upgrade pip setuptools wheel
RUN if [ "x$SPINUP_ENV" = "xDEV" ]; then python -m pip install pipenv pipx; fi
RUN if [ "x$SPINUP_ENV" = "xDEV" ]; then pipx ensurepath ; fi

FROM builder AS projectenv

# Set our work directory
WORKDIR /project

# Add an application user
RUN useradd -m -r appuser && \
    chown appuser /project

COPY . .

RUN if [ "x$SPINUP_ENV" = "xPROD" ]; then pip install -r requirements.txt; fi

USER appuser

RUN if [ "x$SPINUP_ENV" = "xDEV" ] ; then (cd /project ; pipenv install) ; fi

LABEL name="tammymakesthings_pyorgcli"
LABEL version="0.1.0"
LABEL author="Tammy Cravit <tammymakesthings@gmail.com>"
