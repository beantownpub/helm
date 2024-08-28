
name ?= psql
port ?= ${DB_PORT}
namespace ?= ${DB_NAMESPACE}
tag ?= latest
pvc_enabled ?= false


## Install psql database in cluster
db/install:
	kubectl config use-context $(context) && \
	cd psql/ && \
	helm upgrade --install $(name) . \
		--namespace $(namespace) \
		--set image.tag=$(tag) \
		--set db_admin_pass=${DB_ADMIN_PASS} \
		--set db_admin_user=${DB_ADMIN_USER} \
		--set db_pass=${DB_PASS} \
		--set db_user=${DB_USER} \
		--set contactDbName=${CONTACT_DB_NAME} \
		--set contentDbName=${CONTENT_DB_NAME} \
		--set menuDbName=${MENU_DB_NAME} \
		--set merchDbName=${MERCH_DB_NAME} \
		--set usersDbName=${USERS_DB_NAME} \
		--set pvc.enabled=$(pvc_enabled) \
		--debug

db/template:
  cd psql/ && \
	helm template $(name) . \
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
		--set pvc.enabled=$(pvc_enabled) \
		--debug

db/port_forward:
		kubectl port-forward --namespace $(namespace) svc/$(name) $(port):$(port)

db/stop_pf:
		./scripts/stop_port_forward.sh $(port)
