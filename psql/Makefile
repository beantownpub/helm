
name ?= psql
port ?= ${DB_PORT}
namespace ?= ${DB_NAMESPACE}
tag ?= latest
pvc_enabled ?= false
region_code ?= use1


## Install psql database in cluster
db/install:
	helm upgrade --install psql . \
		--kubeconfig="${HOME}"/.kube/$(kubeconfig) \
		--namespace ${DB_NAMESPACE} \
		--set pvc.enabled=$(pvc_enabled) \
		--set environment=$(environment) \
		--set regionCode=$(region_code) \
		--debug

## Run helm template on psql chart
db/wtf:
	cd psql/ && \
	helm template . \
		--namespace ${DB_NAMESPACE} \
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
