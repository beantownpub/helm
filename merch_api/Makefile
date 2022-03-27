.PHONY: all test clean
SHELL := /bin/bash
export MAKE_PATH ?= $(shell pwd)

name := $(subst _,-,$(@D))
# tag = $(shell grep 'appVersion:' $(@D)/Chart.yaml | cut -f 2 -d' ')
port := ${MERCH_API_PORT}
log_level := ${MERCH_API_LOG_LEVEL}


merch/context:
	kubectl config use-context $(context)

## Publish merch-api Helm chart
merch_api/publish:
	cd merch_api && helm package . && \
		cd - && \
		helm repo index . --url https://beantownpub.github.io/helm/ && \
		git add merch_api/

## Deploy merch-api to cluster
merch_api/install: merch/context
	cd $(@D)/ && \
	helm upgrade $(subst _,-,$(@D)) . \
		--namespace $(namespace) \
		--set global.env=$(env) \
		--set image.tag=$(shell grep 'appVersion:' $(@D)/Chart.yaml | cut -f 2 -d' ') \
		--set api_user=${API_USER} \
		--set api_pass=${API_PASS} \
		--set db_host=${DB_HOST} \
		--set db_pass=${DB_PASS} \
		--set db_port="5432" \
		--set db_user=${DB_USER} \
		--set db_name=${MERCH_DB_NAME} \
		--set frontend_origin_url=${FRONTEND_ORIGIN_URL} \
		--set logLevel=$(log_level) \
		--set domain=$(domain) \
		--install \
		--debug

## Render merch-api templates
merch/template:
	cd merch_api/ && \
	helm template . \
		--namespace=$(namepsace) \
		--name-template=$(name) \
		--set global.env=$(env) \
		--set image.tag=$(tag) \
		--set api_user=${API_USER} \
		--set api_pass=${API_PASS} \
		--set db_host=${DB_HOST} \
		--set db_pass=${DB_PASS} \
		--set db_port="${DB_PORT}" \
		--set db_user=${DB_USER} \
		--set db_name=${MERCH_DB_NAME} \
		--set frontend_origin_url=${FRONTEND_ORIGIN_URL} \
		--debug

merch_api/port_forward: merch/context
	kubectl port-forward --namespace $(namespace) svc/$(name) ${MERCH_API_PORT}:${MERCH_API_PORT}
