
name ?= users-api
image ?= users_api
tag ?= $(shell grep 'appVersion:' Chart.yaml | cut -f 2 -d' ')
port ?= 5045
log_level ?= DEBUG

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
		--set image.name=$(image) \
		--set image.tag=$(tag) \
		--set logLevel=$(log_level) \
		--debug

template:
		helm template . \
			--name-template=$(name) \
			--set global.env=$(env) \
			--set image.name=$(image) \
			--set image.tag=$(tag) \
			--debug


port_forward:
		kubectl port-forward --namespace $(namespace) svc/$(name) $(port):$(port)

stop_pf:
		../scripts/stop_port_forward.sh $(namespace) $(name)

logs:
		../scripts/get_pod_logs.sh $(namespace) $(name)

describe:
		../scripts/describe_pod.sh $(namespace) $(name)

kill_pod:
		../scripts/kill_pod.sh $(namespace) $(name)

secret:
	kubectl create secret generic users-api-creds \
		--namespace $(namespace) \
		--from-literal=default_admin_email="${DEFAULT_ADMIN_EMAIL}" \
		--from-literal=default_admin_user="${DEFAULT_ADMIN_USER}" \
		--from-literal=default_admin_pass="${DEFAULT_ADMIN_PASS}" \
		--from-literal=db_name="${USERS_DB_NAME}"
