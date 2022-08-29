.PHONY: all test clean
SHELL := /bin/bash

name ?= $(subst _,-,$(@D))
image := menu_api
#tag := $(shell grep 'appVersion:' $(@D)/Chart.yaml | cut -f 2 -d' ')
port := ${MENU_API_PORT}
log_level ?= ${MENU_API_LOG_LEVEL}

ifeq ($(env),dev)
	context = ${DEV_CONTEXT}
	namespace = ${DEV_NAMESPACE}
else ifeq ($(env),prod)
	context = ${PROD_CONTEXT}
	namespace = ${PROD_NAMESPACE}
endif

menu/clean:
		rm *.tgz || true

menu/context:
	kubectl config use-context $(context)

## Publish menu-api Helm chart
menu_api/publish:
	cd menu_api && \
		helm package . && \
		cd - && \
		helm repo index . --url https://beantownpub.github.io/helm/ && \
		git add menu_api/

## Deploy menu-api to a cluster
menu/install: menu/context
	@echo "\033[1;32m. . . Installing menu-api in $(env) . . .\033[1;37m\n"
	cd menu_api && \
	helm upgrade --install menu-api . \
		--namespace $(namespace) \
		--set global.env=$(env) \
		--set image.name=$(image) \
		--set db_name=${MENU_DB_NAME} \
		--set image.tag=$(tag) \
		--set logLevel=$(log_level) \
		--debug

menu/template:
	@echo "\033[1;32m. . . Templating menu-api in $(env) . . .\033[1;37m\n"
	cd menu_api && \
	helm template . \
		--name-template=$(name) \
		--set global.env=$(env) \
		--set image.name=$(image) \
		--set image.tag=$(tag) \
		--set logLevel=$(log_level) \
		--debug

## Forward menu-api port
menu_api/port_forward: menu/context
		kubectl port-forward --namespace $(namespace) svc/$(name) $(port):$(port)

menu/stop_pf:
		../scripts/stop_port_forward.sh $(port)

menu/logs:
		../scripts/get_pod_logs.sh $(namespace) $(name)

menu/describe:
		../scripts/describe_pod.sh $(namespace) $(name)

## Delete menu-api pod
menu/kill: menu/context
		./scripts/kill_pod.sh $(namespace) $(name)
