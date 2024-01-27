#
# Makefile for local development for the serlo KPI project.
#

IMAGES := gsutil-base dbdump dbsetup mongodb-tools-base grafana varnish
include mk/help.mk

.PHONY: _help
# print help as the default target.
# since hte actual help recipe is quite long, it is moved
# to the bottom of this makefile.
_help: help

# forbid parallel building of prerequisites
.NOTPARALLEL:

.PHONY: build_minikube_%
# build a specific docker image for minikube
build_minikube_%:
	@set -e ; eval "$(DOCKER_ENV)" && if test -d container/$* ; then $(MAKE) -C container/$* docker_build_minikube; fi

.PHONY: build_minikube_forced_%
# force rebuild of a specific docker image
build_minikube_forced_%:
	@set -e ; eval "$(DOCKER_ENV)" && if test -d container/$* ; then $(MAKE) -C container/$* docker_build; fi

.PHONY: build_ci_%
# build a specific docker image for CI
build_ci_%:
	$(MAKE) -C container/$* docker_build_ci

.PHONY: build_minikube
# build docker images for local dependencies in the cluster
build_minikube: $(foreach CONTAINER,$(IMAGES),build_minikube_$(CONTAINER))

.PHONY: build_minikube_forced
# build docker images for local dependencies in the cluster (forced rebuild)
build_minikube_forced: $(foreach CONTAINER,$(IMAGES),build_minikube_forced_$(CONTAINER))

.PHONY: build_ci
# build docker images for local dependencies in the cluster
build_ci: $(foreach CONTAINER,$(IMAGES),build_ci_$(CONTAINER))



# COLORS
GREEN  := $(shell tput -Txterm setaf 2)
YELLOW := $(shell tput -Txterm setaf 3)
BLUE   := $(shell tput -Txterm setaf 4)
WHITE  := $(shell tput -Txterm setaf 7)
RESET  := $(shell tput -Txterm sgr0)
DIM  := $(shell tput -Txterm dim)
