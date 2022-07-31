.PHONY: all test clean

name ?= thehubpub
image ?= hubpub
port ?= 3037
tag ?= $(shell grep 'appVersion:' Chart.yaml | cut -f 2 -d' ')

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

context:
	kubectl config use-context $(context)

install:
	helm upgrade --install $(name) . \
		--namespace $(namespace) \
		--set global.env=$(env) \
		--debug

template:
	helm template . \
		--name-template=$(name) \
		--namespace $(namespace) \
		--set global.env=$(env) \
		--debug

port_forward:
		kubectl port-forward --namespace $(namespace) svc/$(name) $(port):$(port)

stop_pf:
		../scripts/stop_port_forward.sh $(port)
