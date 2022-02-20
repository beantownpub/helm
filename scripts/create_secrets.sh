#!/bin/bash
set -eo pipefail

NAMESPACE=${1}

kubectl create secret generic db-creds \
  --namespace database \
  --from-literal=db_admin_user="${DB_ADMIN_USER}" \
  --from-literal=db_admin_pass="${DB_ADMIN_PASS}" \
  --from-literal=db_user="${DB_USER}" \
  --from-literal=db_pass="${DB_PASS}"

kubectl create secret generic app-creds \
  --namespace "${NAMESPACE}" \
  --from-literal=default_admin_user="${DEFAULT_ADMIN_USER}" \
  --from-literal=default_admin_pass="${DEFAULT_ADMIN_PASS}" \
  --from-literal=api_user="${API_USER}" \
  --from-literal=api_pass="${API_PASS}" \
  --from-literal=db_host="${DB_HOST}" \
  --from-literal=db_pass="${DB_PASS}" \
  --from-literal=db_port="${DB_PORT}" \
  --from-literal=db_user="${DB_USER}" \
  --from-literal=menu_db_name="${MENU_DB_NAME}" \
  --from-literal=users_db_name="${USERS_DB_NAME}"

