#                   ___                         ___           ___           ___                         ___           ___
#      ___         /\  \                       /\__\         /\  \         /\  \          ___          /\__\         /\__\
#     /\__\       /::\  \                     /:/ _/_       /::\  \       /::\  \        /\  \        /:/ _/_       /:/ _/_
#    /:/__/      /:/\:\  \                   /:/ /\  \     /:/\:\__\     /:/\:\  \       \:\  \      /:/ /\__\     /:/ /\  \
#   /::\  \     /:/ /::\  \   ___     ___   /:/ /::\  \   /:/ /:/  /    /:/ /::\  \       \:\  \    /:/ /:/ _/_   /:/ /::\  \
#   \/\:\  \   /:/_/:/\:\__\ /\  \   /\__\ /:/__\/\:\__\ /:/_/:/__/___ /:/_/:/\:\__\  ___  \:\__\  /:/_/:/ /\__\ /:/_/:/\:\__\
#    ~~\:\  \  \:\/:/  \/__/ \:\  \ /:/  / \:\  \ /:/  / \:\/:::::/  / \:\/:/  \/__/ /\  \ |:|  |  \:\/:/ /:/  / \:\/:/ /:/  /
#       \:\__\  \::/__/       \:\  /:/  /   \:\  /:/  /   \::/~~/~~~~   \::/__/      \:\  \|:|  |   \::/_/:/  /   \::/ /:/  /
#       /:/  /   \:\  \        \:\/:/  /     \:\/:/  /     \:\~~\        \:\  \       \:\__|:|__|    \:\/:/  /     \/_/:/  /
#      /:/  /     \:\__\        \::/  /       \::/  /       \:\__\        \:\__\       \::::/__/      \::/  /        /:/  /
#      \/__/       \/__/         \/__/         \/__/         \/__/         \/__/        ~~~~           \/__/         \/__/

.PHONY: all test clean
SHELL := /bin/bash

context ?= ${CONTEXT}
domain ?= jalgraves.com

ONESHELL:

deps:
	helm dependencies update

namespace:
	kubectl config use-context $(context)
	kubectl create namespace istio-ingress && \
        kubectl label namespace istio-ingress istio-injection=enabled

template:
	helm template . \
		--namespace istio-ingress \
		--name-template=default-ingress \
		--set global.env=$(env) \
		--set domain=$(domain) \
		--set additionalHosts="{foo.com, bar.buzz}" \
		--debug

install:
	kubectl config use-context $(context)
	helm upgrade --install istio-ingress . \
		--debug
