-include psql/Makefile
-include merch_api/Makefile
.PHONY: all test clean help
export MAKE_PATH ?= $(shell pwd)
export SELF ?= $(MAKE)
SHELL := /bin/bash

MAKE_FILES = ${MAKE_PATH}/**/Makefile ${MAKE_PATH}/Makefile

name=$(firstword $(subst _,-,$(@D)))


ifdef env
	ifeq ($(env),dev)
		context = ${DEV_CONTEXT}
		namespace = ${DEV_NAMESPACE}
		domain ?= jalgraves.com
	else ifeq ($(env),prod)
		context = ${PROD_CONTEXT}
		namespace = ${PROD_NAMESPACE}
	else
		env := dev
	endif
endif

## Add Helm repos
helm/repos/add:
	helm repo add istio https://istio-release.storage.googleapis.com/charts && \
		helm repo add jetstack https://charts.jetstack.io && \
		helm repo update

context:
	kubectl config use-context $(context)

## Install Cilium CNI
cilium/install: update context
	@echo "\033[1;32m. . . Installing Cilium CNI . . .\033[1;37m\n"
	helm upgrade cilium cilium/cilium --install \
		--version 1.10.5 \
		--namespace kube-system --reuse-values \
		--set hubble.relay.enabled=true \
		--set hubble.ui.enabled=true \
		--set ipam.operator.clusterPoolIPv4PodCIDR="10.7.0.0/16"\
		--debug

## Publish istio Argo-CD chart
argo/publish:
	cd argo-cd/ && helm package . && \
		cd - && \
		helm repo index . --url https://beantownpub.github.io/helm/ && \
		git add argo-cd/


## Publish istio Helm chart
istio/publish:
	cd istio/ && helm package . && \
		cd - && \
		helm repo index . --url https://beantownpub.github.io/helm/ && \
		git add istio/

## Publish pod-identity-webhook Helm chart
pod-identity-webhook/publish:
	cd pod-identity-webhook/ && helm package . && \
		cd - && \
		helm repo index . --url https://beantownpub.github.io/helm/ && \
		git add pod-identity-webhook/

namespaces: context
	@echo "\033[1;32m. . . Installing $(env) namespaces . . .\033[1;37m\n"
	kubectl create ns $(env) && \
		kubectl create ns database && \
		kubectl label namespace $(env) istio-injection=enabled

app/creds/secret: context
	@echo "\033[1;32m. . . Installing creds $(env) secret . . .\033[1;37m\n"
	kubectl create secret generic app-creds \
		--namespace $(namespace) \
		--from-literal=api_user="${API_USER}" \
		--from-literal=api_pass="${API_PASS}" \
		--from-literal=db_host="${DB_HOST}" \
		--from-literal=db_pass="${DB_PASS}" \
		--from-literal=db_port="${DB_PORT}" \
		--from-literal=db_user="${DB_USER}"

## Publish admin Helm chart
admin/publish:
	cd admin && helm package . && \
		cd - && \
		helm repo index . --url https://beantownpub.github.io/helm/ && \
		git add admin/

## Publish db Helm chart
db/publish:
	cd psql && helm package . && \
		cd - && \
		helm repo index . --url https://beantownpub.github.io/helm/ && \
		git add psql/

secrets: app/creds/secret app/services/secret users/secret app/square/secret

deploy: context namespaces secrets db/install

## Create common apps secret
app/services/secret/create: context
	@echo "\033[1;32m. . . Installing external services secret . . .\033[1;37m\n"
	kubectl create secret generic services \
		--namespace $(namespace) \
		--from-literal=contact_api_host="${CONTACT_API_HOST}" \
		--from-literal=contact_api_port="${CONTACT_API_PORT}" \
		--from-literal=contact_api_protocol="${CONTACT_API_PROTOCOL}" \
		--from-literal=menu_api_host="${MENU_API_HOST}" \
		--from-literal=menu_api_port="${MENU_API_PORT}" \
		--from-literal=menu_api_protocol="${MENU_API_PROTOCOL}" \
		--from-literal=merch_api_host="${MERCH_API_HOST}" \
		--from-literal=merch_api_port="${MERCH_API_PORT}" \
		--from-literal=merch_api_protocol="${MERCH_API_PROTOCOL}" \
		--from-literal=users_api_host="${USERS_API_HOST}" \
		--from-literal=users_api_port="${USERS_API_PORT}" \
		--from-literal=users_api_protocol="${USERS_API_PROTOCOL}"

## Delete services secret
app/services/secret/delete: context
	kubectl delete secret -n $(namespace) services

## Delete and recreate services secret
app/services/secret/recreate: app/services/secret/delete app/services/secret/create

## Create apps square secret
app/square/secret: context
	@echo "\033[1;32m. . . Installing square secret . . .\033[1;37m\n"
	kubectl create secret generic square \
		--namespace $(namespace) \
		--from-literal=square_access_token_dev="${SQUARE_ACCESS_TOKEN_DEV}" \
		--from-literal=square_access_token_prod="${SQUARE_ACCESS_TOKEN_PROD}" \
		--from-literal=square_location_id="${SQUARE_LOCATION_ID}" \
		--from-literal=square_url="${SQUARE_URL}" \
		--from-literal=square_application_id_sandbox="${SQUARE_APPLICATION_ID_SANDBOX}"

cert_manager/install:
	helm install \
		cert-manager jetstack/cert-manager \
		--namespace cert-manager \
		--create-namespace \
		--version v1.6.1 \
		--set prometheus.enabled=false

## Show available commands
help:
	@printf "Available targets:\n\n"
	@$(SELF) -s help/generate | grep -E "\w($(HELP_FILTER))"
	@printf "\n"

help/generate:
	@awk '/^[a-zA-Z\_0-9%:\\\/-]+:/ { \
		helpMessage = match(lastLine, /^## (.*)/); \
		if (helpMessage) { \
			helpCommand = $$1; \
			helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
			gsub("\\\\", "", helpCommand); \
			gsub(":+$$", "", helpCommand); \
			printf "  \x1b[32;01m%-35s\x1b[0m %s\n", helpCommand, helpMessage; \
		} \
	} \
	{ lastLine = $$0 }' $(MAKE_FILES) | sort -u

## Install Admin frontend
admin/install: context
	cd admin && make install env=$(env) context=$(context)

## Uninstall Admin frontend
admin/delete: context
	cd admin && make delete env=$(env) context=$(context)

## Forward Beantown admin port locally
admin/port_forward: context
	kubectl port-forward --namespace $(namespace) svc/beantown-admin 3033:3033

## Forward port for Cilium Hubble UI
hubble/port_forward:
	kubectl port-forward --namespace kube-system svc/hubble-ui 80:8080

## Stop port-forwarding
stop_pf: context
	./scripts/stop_port_forward.sh $(port) || true

kill_pod: context
	./scripts/kill_pod.sh $(namespace) $(pod)

logs: context
	./scripts/get_pod_logs.sh $(namespace) $(pod)

buzz ?= $(subst _,-,$(@D))
foo_bar/install:
	@echo $@
	@echo "buzz $(buzz)"
	@echo $(tag)
	@echo $(subst _,-,$(@D))

istio/template:
	helm template istio istio/ \
		-f istio/$(istio_values) \
		--namespace istio-system \
		--create-namespace \
		--debug

istio/install:
	helm upgrade --install istio istio/ \
		--namespace istio-system \
		--kubeconfig=$(kubeconfig) \
		-f istio/$(istio_values) \
		--create-namespace \
		--debug
