
name ?= postgres
port ?= ${DB_PORT}
namespace ?= ${DB_NAMESPACE}
tag ?= latest

ifeq ($(env),dev)
	context = ${DEV_CONTEXT}
else ifeq ($(env),prod)
	context = ${PROD_CONTEXT}
else
	@$(SELF) -s help/generate
endif

install:
	kubectl config use-context $(context)
	helm upgrade --install $(name) . \
		--namespace $(namespace) \
		--set image.tag=$(tag) \
		--debug

db/template:
	helm template postgres \
		--namespace $(namespace) \
		--name-template=$(name) \
		--set image.tag=$(tag) \
		--debug

db/port_forward:
		kubectl port-forward --namespace $(namespace) svc/$(name) $(port):$(port)

db/stop_pf:
		./scripts/stop_port_forward.sh $(port)

db/secret:
	kubectl create secret generic db-creds \
		--namespace "${DB_NAMESPACE}" \
		--from-literal=db_admin_user="${DB_ADMIN_USER}" \
		--from-literal=db_admin_pass="${DB_ADMIN_PASS}" \
		--from-literal=db_user="${DB_USER}" \
		--from-literal=db_pass="${DB_PASS}" \
		--from-literal=contact_db_name="${CONTACT_DB_NAME}" \
		--from-literal=menu_db_name="${MENU_DB_NAME}" \
		--from-literal=merch_db_name="${MERCH_DB_NAME}" \
		--from-literal=users_db_name="${USERS_DB_NAME}"
