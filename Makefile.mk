EDITOR=vim
SHELL = /bin/bash
UNAME = $(shell uname -s)

ifeq ($(UNAME),Linux)
include /etc/os-release
endif
ID_U = $(shell id -un)
ID_G = $(shell id -gn)
# enable trace in shell
DEBUG ?= 
#
# Tricks to uppper case
#
UC = $(shell echo '$1' | tr '[:lower:]' '[:upper:]')
#
# docker-compose options
#
DOCKER_USE_TTY := $(shell test -t 1 && echo "-t" )
DC_USE_TTY     := $(shell test -t 1 || echo "-T" )


# global docker prefix
COMPOSE_PROJECT_NAME ?= tableau

DC_TABLEAU_DEFAULT_CONF ?= docker-compose.yml
DC_TABLEAU_CUSTOM_CONF ?= docker-compose-custom.yml

DC_TABLEAU_BUILD_CONF ?= -f docker-compose-build.yml
DC_TABLEAU_RUN_CONF ?= -f ${DC_TABLEAU_DEFAULT_CONF}
# detect custom docker-compose file
ifneq ("$(wildcard ${DC_TABLEAU_CUSTOM_CONF})","")
DC_TABLEAU_RUN_CONF += -f ${DC_TABLEAU_CUSTOM_CONF}
endif

DOCKER_REGISTRY ?= ghcr.io
DOCKER_REPOSITORY ?= pli01/tableau-server-docker
#
# tableau server build version
#
TABLEAU_SERVER_IMAGE_VERSION ?= latest
TABLEAU_SERVER_CONTAINER_SETUP_TOOL_VERSION ?= 2021.2.0
TABLEAU_SERVER_RPM_VERSION ?= 2021-2-0
JDBC_POSTGRESQL_VERSION ?= 42.2.14
JDBC_MYSQL_VERSION ?= 8.0.26-1
#
# tableau server run
#
TABLEAU_PORT ?= 80
LICENSE_KEY ?=
TSM_REMOTE_PASSWORD ?=
PUBLIC_HOST ?= localhost
