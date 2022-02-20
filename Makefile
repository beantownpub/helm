# -include postgres/Makefile
.PHONY: all test clean
export MAKE_PATH ?= $(shell pwd)
export SELF ?= $(MAKE)
SHELL := /bin/bash

MAKE_FILES = ${MAKE_PATH}/**/Makefile ${MAKE_PATH}/Makefile

ifeq ($(env),dev)
	context = ${DEV_CONTEXT}
	namespace = ${DEV_NAMESPACE}
else ifeq ($(env),prod)
	context = ${PROD_CONTEXT}
	namespace = ${PROD_NAMESPACE}
else
	env := dev
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

istio/base/install: update context
	@echo "\033[1;32m. . . Installing Istio base . . .\033[1;37m\n"
	helm upgrade istio-base istio/base --install \
		--namespace istio-system \
		--version 1.12.1 \
        --create-namespace

istio/istiod/install: update context
	@echo "\033[1;32m. . . Installing Istiod . . .\033[1;37m\n"
	helm upgrade istiod istio/istiod --install \
		--version 1.12.1 \
        --namespace istio-system

gateway_ns: context
	@echo "\033[1;32m. . . Installing istio-ingress namespace . . .\033[1;37m\n"
	kubectl create namespace istio-ingress && \
		kubectl label namespace istio-ingress istio-injection=enabled

istio/gateway/install: context
	@echo "\033[1;32m. . . Installing Istio Gateway . . .\033[1;37m\n"
	helm upgrade istio-ingress istio/gateway --install \
		--version 1.12.1 \
        --namespace istio-ingress \
        --set service.type=None && \
		kubectl apply -n istio-ingress -f istio-ingress/templates

## Install Istio
istio/install: istio/base/install istio/istiod/install gateway_ns istio/gateway/install

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

## Create Contact API secret
contact/secret: context
	@echo "\033[1;32m. . . Installing contact-api $(env) secret . . .\033[1;37m\n"
	cd contact_api && make secret env=$(env)

## Helm template Contact API secret
contact/template: context
	@echo "\033[1;32m. . . Helm templating contact-api $(env) . . .\033[1;37m\n"
	cd contact_api && make template env=$(env)

## Publish contact Helm chart
contact/publish:
	cd contact_api && helm package . && \
		cd - && \
		helm repo index . --url https://beantownpub.github.io/helm/ && \
		git add contact_api/

## Create database secret
db/secret: context
	@echo "\033[1;32m. . . Installing DB $(env) secret . . .\033[1;37m\n"
	cd postgres && make db/secret env=$(env)

## Create Menu API secret
menu/secret: context
	@echo "\033[1;32m. . . Installing menu-api $(env) secret . . .\033[1;37m\n"
	cd menu_api && make secret env=$(env)

## Create Merch API secret
merch/secret: context
	@echo "\033[1;32m. . . Installing merch-api $(env) secret . . .\033[1;37m\n"
	cd merch_api && make secret env=$(env)

## Create Users API secret
users/secret: context
	@echo "\033[1;32m. . . Installing users-api $(env) secret . . .\033[1;37m\n"
	cd users_api && make secret env=$(env)

secrets: app/creds/secret app/services/secret contact/secret db/secret menu/secret merch/secret users/secret app/square/secret beantown/secret

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
	@printf "\n\n"

## Install Contact API
contact/install: context
	@echo "\033[1;32m. . . Installing contact-api in $(env) . . .\033[1;37m\n"
	cd contact_api && make install env=$(env) context=$(context)

## Recreate Contact API secret
contact/secret/recreate: context
	@echo "\033[1;32m. . . Installing contact-api in $(env) . . .\033[1;37m\n"
	cd contact_api && make secret/recreate env=$(env) context=$(context)

## Forward contact-api port locally
contact/port_forward: context
	kubectl port-forward --namespace $(namespace) svc/contact-api 5012:5012

## Install database
db/install: context
	@echo "\033[1;32m. . . Installing DB in $(env) . . .\033[1;37m\n"
	cd postgres && make install env=$(env) context=$(context)

## Install Users API
users/install: context
	@echo "\033[1;32m. . . Installing users-api in $(env) . . .\033[1;37m\n"
	cd users_api && make install env=$(env) context=$(context)

## Install Menu API
menu/install: context
	@echo "\033[1;32m. . . Installing menu-api in $(env) . . .\033[1;37m\n"
	cd menu_api && make install env=$(env) context=$(context)

## Forward menu-api port locally
menu/port_forward: context
	kubectl port-forward --namespace $(namespace) svc/menu-api 5004:5004

## Install Merch API
merch/install: context
	@echo "\033[1;32m. . . Installing menu-api in $(env) . . .\033[1;37m\n"
	cd merch_api && make install env=$(env) context=$(context)

## Forward merch-api port locally
merch/port_forward: context
	kubectl port-forward --namespace $(namespace) svc/merch-api 5000:5000

## Install Admin frontend
admin/install: context
	cd admin && make install env=$(env) context=$(context)

## Uninstall Admin frontend
admin/delete: context
	cd admin && make delete env=$(env) context=$(context)

## Forward Beantown admin port locally
admin/port_forward: context
	kubectl port-forward --namespace $(namespace) svc/beantown-admin 3033:3033

## Create Beantown secret
beantown/secret: context
	@echo "\033[1;32m. . . Installing beantown $(env) secret . . .\033[1;37m\n"
	cd beantown && make secret env=$(env)

## Install Beantownpub frontend
beantown/install: context
	cd beantown && make install env=$(env) context=$(context)

## Forward Beantownpub port locally k8s_port:local_port
beantown/port_forward: context
	kubectl port-forward --namespace $(namespace) svc/beantown 3000:3000

## Install Thehubpub frontend
thehubpub/install: context
	cd thehubpub && make install env=$(env) context=$(context)

## Forward The Hub Pub port locally k8s_port:local_port
thehubpub/port_forward: context
	kubectl port-forward --namespace $(namespace) svc/thehubpub 3037:3037

## Install Wavelengths frontend
wavelengths/install: context
	cd wavelengths && make install env=$(env) context=$(context)

## Install DrDavisIceCream frontend
drdavisicecream/install: context
	cd drdavisicecream && make install env=$(env) context=$(context)

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
