.PHONY: all test clean

name := $(subst _,-,$(@D))
image := contact-api
# tag := $(shell grep 'appVersion:' $(@D)/Chart.yaml | cut -f 2 -d' ')
port := 5012

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
endif

contact/clean:
		rm contact_api/*.tgz || true

contact/context:
	kubectl config use-context $(context)

## Publish contact Helm chart
contact/publish:
	cd contact_api && helm package . && \
		cd - && \
		helm repo index . --url https://beantownpub.github.io/helm/ && \
		git add contact_api/

## Deploy contact-api to cluster
contact_api/install: contact/context
	cd contact_api && \
	helm upgrade --install contact-api . \
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
		--set test_email_recipient="${TEST_EMAIL_RECIPIENT}" \
		--debug
	@echo $(name)

## Render contact-api templates
contact/template:
	cd contact_api && \
	helm template beantown/contact-api \
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

contact/port_forward: contact/context
		kubectl port-forward --namespace $(namespace) svc/$(name) $(port):$(port)
