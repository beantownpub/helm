#!/bin/bash
set -eo pipefail

NAMESPACE=${1}

kubectl create secret generic services \
  --namespace "${NAMESPACE}" \
  --from-literal=contact_api_host="${CONTACT_API_HOST}" \
  --from-literal=contact_api_protocol="${CONTACT_API_PROTOCOL}" \
  --from-literal=menu_api_host="${MENU_API_HOST}" \
  --from-literal=menu_api_protocol="${MENU_API_PROTOCOL}" \
  --from-literal=merch_api_host="${MERCH_API_HOST}" \
  --from-literal=merch_api_protocol="${MERCH_API_PROTOCOL}" \
  --from-literal=users_api_host="${USERS_API_HOST}" \
  --from-literal=users_api_protocol="${USERS_API_PROTOCOL}"
