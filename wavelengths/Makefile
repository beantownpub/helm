.PHONY: all test clean

name ?= wavelengths
image ?= wavelengths
tag ?= $(shell grep 'appVersion:' Chart.yaml | cut -f 2 -d' ')

ifeq ($(env),dev)
	context = ${DEV_CONTEXT}
	namespace = ${DEV_NAMESPACE}
else ($(env),prod)
	context = ${PROD_CONTEXT}
	namespace = ${PROD_NAMESPACE}
endif

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
