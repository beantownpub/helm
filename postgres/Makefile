
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
		--set contact_db_name=${CONTACT_DB_NAME} \
		--set db_admin_pass=${DB_ADMIN_PASS} \
		--set db_admin_user=${DB_ADMIN_USER} \
		--set db_pass=${DB_PASS} \
		--set db_user=${DB_USER} \
		--set menu_db_name=${MENU_DB_NAME} \
		--set merch_db_name=${MERCH_DB_NAME} \
		--set users_db_name=${USERS_DB_NAME} \
		--debug

template:
	helm template . \
		--namespace $(namespace) \
		--name-template=$(name) \
		--set image.tag=$(tag) \
		--set contact_db_name=${CONTACT_DB_NAME} \
		--set db_admin_pass=${DB_ADMIN_PASS} \
		--set db_admin_user=${DB_ADMIN_USER} \
		--set db_pass=${DB_PASS} \
		--set db_user=${DB_USER} \
		--set menu_db_name=${MENU_DB_NAME} \
		--set merch_db_name=${MERCH_DB_NAME} \
		--set users_db_name=${USERS_DB_NAME} \
		--debug

db/port_forward:
		kubectl port-forward --namespace $(namespace) svc/$(name) $(port):$(port)

db/stop_pf:
		./scripts/stop_port_forward.sh $(port)
