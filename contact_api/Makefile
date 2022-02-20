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
			--set aws_access_key_id="${AWS_ACCESS_KEY_ID}" \
			--set aws_secret_access_key="${AWS_SECRET_ACCESS_KEY}" \
			--set aws_default_region="${AWS_DEFAULT_REGION}" \
			--set email_recipient="$(email_recipient)" \
			--set second_email_recipient="${SECOND_EMAIL_RECIPIENT}" \
			--set slack_channel="${SLACK_WEBHOOK_CHANNEL}" \
			--set slack_user="${SLACK_USER}" \
			--set slack_webhook_url="${SLACK_WEBHOOK_URL}" \
			--set support_email_address="${SUPPORT_EMAIL_ADDRESS}" \
			--set support_phone_number="${SUPPORT_PHONE_NUMBER}" \
			--set slack_partys_channel="${SLACK_PARTYS_CHANNEL}" \
			--set slack_orders_channel="${SLACK_ORDERS_CHANNEL}" \
			--set slack_orders_webhook_url=$(slack_orders_webhook_url) \
			--set slack_partys_webhook_url=$(slack_partys_webhook_url) \
			--debug

template:
		helm template . \
			--name-template=$(name) \
			--namespace $(namespace) \
			--set global.env=$(env) \
			--set logLevel=$(log_level) \
			--set aws_access_key_id="${AWS_ACCESS_KEY_ID}" \
			--set aws_secret_access_key="${AWS_SECRET_ACCESS_KEY}" \
			--set aws_default_region="${AWS_DEFAULT_REGION}" \
			--set email_recipient="$(email_recipient)" \
			--set second_email_recipient="${SECOND_EMAIL_RECIPIENT}" \
			--set slack_channel="${SLACK_WEBHOOK_CHANNEL}" \
			--set slack_user="${SLACK_USER}" \
			--set slack_webhook_url="${SLACK_WEBHOOK_URL}" \
			--set support_email_address="${SUPPORT_EMAIL_ADDRESS}" \
			--set support_phone_number="${SUPPORT_PHONE_NUMBER}" \
			--set slack_partys_channel="${SLACK_PARTYS_CHANNEL}" \
			--set slack_orders_channel="${SLACK_ORDERS_CHANNEL}" \
			--set slack_orders_webhook_url=$(slack_orders_webhook_url) \
			--set slack_partys_webhook_url=$(slack_partys_webhook_url) \
			--debug

port_forward:
		kubectl port-forward --namespace $(namespace) svc/$(name) $(port):$(port)
