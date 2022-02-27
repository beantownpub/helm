.PHONY: all test clean

name ?= beantown
image ?= beantown
env ?= dev
tag ?= $(shell grep 'appVersion:' Chart.yaml | cut -f 2 -d' ')
port ?= ${BEANTOWN_PORT}

ifeq ($(env),dev)
	context = ${DEV_CONTEXT}
	namespace = ${DEV_NAMESPACE}
	square_url = ${SQUARE_URL_DEV}
else
	context = ${PROD_CONTEXT}
	namespace = ${PROD_NAMESPACE}
	square_url = ${SQUARE_URL_PROD}
endif

install:
	kubectl config use-context $(context)
	helm upgrade --install beantown . \
		--namespace $(namespace) \
		--set image.tag=0.1.24 \
		--set global.env=$(env) \
		--set session_secret=${SESSION_SECRET} \
		--set square_access_token_dev=${SQUARE_ACCESS_TOKEN_DEV} \
		--set square_access_token_prod=${SQUARE_ACCESS_TOKEN_PROD} \
		--set square_application_id_sandbox=${SQUARE_APPLICATION_ID_SANDBOX} \
		--set square_url=$(square_url) \
		--debug

delete:
	kubectl config use-context $(context)
	helm uninstall $(name) -n $(namespace)

template:
	helm template . \
		--namespace $(namespace) \
		--name-template=$(name) \
		--set global.env=$(env) \
		--debug

.ONESHELL: port_forward

secret:
	kubectl create secret generic beantown-creds \
		--namespace $(namespace) \
		--from-literal=session_secret="${SESSION_SECRET}" \
		--from-literal=square_access_token_dev="${SQUARE_ACCESS_TOKEN_DEV}" \
		--from-literal=square_access_token_prod="${SQUARE_ACCESS_TOKEN_PROD}" \
		--from-literal=square_application_id_sandbox="${SQUARE_APPLICATION_ID_SANDBOX}" \
		--from-literal=square_url="$(square_url)"

port_forward:
	kubectl port-forward --namespace $(namespace) svc/$(name) $(port):$(port)


stop_pf:
	../scripts/stop_port_forward.sh $(port)

logs:
	../scripts/get_pod_logs.sh $(namespace) $(name)
