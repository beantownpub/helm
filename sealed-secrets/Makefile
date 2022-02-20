.PHONY: all test clean
SHELL := /bin/bash

ifeq ($(env),dev)
	context = ${DEV_CONTEXT}
else ifeq ($(env),prod)
	context = ${PROD_CONTEXT}
else
	@echo "No Env specified!"
	exit 1
endif

deps:
	helm dependencies update

install:
	kubectl config use-context $(context)
	helm upgrade --install sealed-secrets . \
		--namespace kube-system \
		--debug
