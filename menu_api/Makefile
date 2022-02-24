.PHONY: all test clean


name ?= menu-api
image ?= menu_api
tag ?= $(shell grep 'appVersion:' Chart.yaml | cut -f 2 -d' ')
port ?= ${MENU_API_PORT}
log_level ?= ${MENU_API_LOG_LEVEL}

ifeq ($(env),dev)
	context = ${DEV_CONTEXT}
	namespace = ${DEV_NAMESPACE}
else ifeq ($(env),prod)
	context = ${PROD_CONTEXT}
	namespace = ${PROD_NAMESPACE}
else
	@echo "No Env specified!"
	exit 1
endif

clean:
		rm *.tgz || true

context:
	kubectl config use-context $(context)

install:
	kubectl config use-context $(context)
	helm upgrade --install $(name) . \
		--namespace $(namespace) \
		--set global.env=$(env) \
		--set image.name=$(image) \
		--set db_name=${MENU_DB_NAME} \
		--set image.tag=$(tag) \
		--set logLevel=$(log_level) \
		--debug

template:
	helm template . \
		--name-template=$(name) \
		--set global.env=$(env) \
		--set image.name=$(image) \
		--set image.tag=$(tag) \
		--set logLevel=$(log_level) \
		--debug


port_forward:
		kubectl port-forward --namespace $(namespace) svc/$(name) $(port):$(port)

stop_pf:
		../scripts/stop_port_forward.sh $(port)

logs:
		../scripts/get_pod_logs.sh $(namespace) $(name)

describe:
		../scripts/describe_pod.sh $(namespace) $(name)

kill_pod:
		../scripts/kill_pod.sh $(namespace) $(name)
