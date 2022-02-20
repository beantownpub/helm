.PHONY: all test clean

name ?= contact-api
image ?= contact_api
tag ?= $(shell grep 'appVersion:' Chart.yaml | cut -f 2 -d' ')
port ?= 5012

ifeq ($(env),dev)
	context = ${DEV_CONTEXT}
	namespace = ${DEV_NAMESPACE}
	slack_orders_webhook_url = ${SLACK_ORDERS_WEBHOOK_URL_DEV}
	slack_partys_webhook_url = ${SLACK_PARTYS_WEBHOOK_URL_DEV}
	email_recipient = ${TEST_EMAIL_RECIPIENT}
	log_level ?= DEBUG
else ifeq ($(env),prod)
	context = ${PROD_CONTEXT}
	namespace = ${PROD_NAMESPACE}
	slack_orders_webhook_url = ${SLACK_ORDERS_WEBHOOK_URL_PROD}
	slack_partys_webhook_url = ${SLACK_PARTYS_WEBHOOK_URL_PROD}
	email_recipient = ${EMAIL_RECIPIENT}
	log_level ?= INFO
else
	@echo "No Env specified!"
	exit 1
endif

clean:
		rm *.tgz || true

install:
		kubectl config use-context $(context)
		helm upgrade --install $(name) . \
			--namespace $(namespace) \
			--set global.env=$(env) \
			--set logLevel=$(log_level) \
			--debug

template:
		helm template . \
			--name-template=$(name) \
			--namespace $(namespace) \
			--set global.env=$(env) \
			--debug

port_forward:
		kubectl port-forward --namespace $(namespace) svc/$(name) $(port):$(port)

secret:
	kubectl create secret generic contact-api-creds \
		--namespace $(namespace) \
		--from-literal=aws_access_key_id="${AWS_ACCESS_KEY_ID}" \
		--from-literal=aws_secret_access_key="${AWS_SECRET_ACCESS_KEY}" \
		--from-literal=aws_default_region="${AWS_DEFAULT_REGION}" \
		--from-literal=email_recipient="$(email_recipient)" \
		--from-literal=second_email_recipient="${SECOND_EMAIL_RECIPIENT}" \
		--from-literal=slack_channel="${SLACK_WEBHOOK_CHANNEL}" \
		--from-literal=slack_user="${SLACK_USER}" \
		--from-literal=slack_webhook_url="${SLACK_WEBHOOK_URL}" \
		--from-literal=support_email_address="${SUPPORT_EMAIL_ADDRESS}" \
		--from-literal=support_phone_number="${SUPPORT_PHONE_NUMBER}" \
		--from-literal=slack_partys_channel="${SLACK_PARTYS_CHANNEL}" \
		--from-literal=slack_orders_channel="${SLACK_ORDERS_CHANNEL}" \
		--from-literal=slack_orders_webhook_url=$(slack_orders_webhook_url) \
		--from-literal=slack_partys_webhook_url=$(slack_partys_webhook_url)

secret/delete:
	kubectl delete secret -n $(namespace) contact-api-creds

secret/recreate: secret/delete secret
