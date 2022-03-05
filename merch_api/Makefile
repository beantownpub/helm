.PHONY: all test clean

name ?= merch-api
tag ?= $(shell grep 'appVersion:' Chart.yaml | cut -f 2 -d' ')
port ?= ${MERCH_API_PORT}
log_level ?= ${MERCH_API_LOG_LEVEL}

ifeq ($(env),dev)
	context = ${DEV_CONTEXT}
	namespace = ${DEV_NAMESPACE}
else ($(env),prod)
	context = ${PROD_CONTEXT}
	namespace = ${PROD_NAMESPACE}
endif

package:
		helm package .

clean:
		rm *.tgz || true

context:
	kubectl config use-context $(context)

install:
	kubectl config use-context $(context)
	helm upgrade --install $(name) . \
		--namespace $(namespace) \
		--set global.env=$(env) \
		--set image.name=$(name) \
		--set image.tag=$(tag) \
		--set api_user=${API_USER} \
		--set api_pass=${API_PASS} \
		--set db_host=${DB_HOST} \
		--set db_pass=${DB_PASS} \
		--set db_port="5432" \
		--set db_user=${DB_USER} \
		--set db_name=${MERCH_DB_NAME} \
		--set frontend_origin_url=${FRONTEND_ORIGIN_URL} \
		--set logLevel=$(log_level) \
		--debug

template:
	helm template . \
		--name-template=$(name) \
		--set global.env=$(env) \
		--set image.name=$(image) \
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


port_forward:
	kubectl port-forward --namespace $(namespace) svc/$(name) $(port):$(port)

secret: context
	kubectl create secret generic merch-api-creds \
		--namespace $(namespace) \
		--from-literal=db_name="${MERCH_DB_NAME}" \
		--from-literal=frontend_origin_url="${FRONTEND_ORIGIN_URL}" \
		--from-literal=flask_secret_key="${FLASK_SECRET_KEY}"
