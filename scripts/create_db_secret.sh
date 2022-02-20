#!/bin/bash
set -eo pipefail

NAMESPACE=${1}

kubectl create secret generic db-creds \
  --namespace "${NAMESPACE}" \
  --from-literal=db_admin_user="${DB_ADMIN_USER}" \
  --from-literal=db_admin_pass="${DB_ADMIN_PASS}" \
  --from-literal=db_user="${DB_USER}" \
  --from-literal=db_pass="${DB_PASS}" \
  --from-literal=contact_db_name="${CONTACT_DB_NAME}" \
  --from-literal=menu_db_name="${MENU_DB_NAME}" \
  --from-literal=db_pass="${MERCH_DB_NAME}" \
  --from-literal=users_db_name="${USERS_DB_NAME}"
