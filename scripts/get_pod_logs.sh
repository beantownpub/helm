#!/bin/bash

POD=$(kubectl get pods -n "${1}" | grep "${2}" | grep -v 'grep' | awk '{print $1}' | head -n 1)

if [[ -n ${POD} ]]; then
    kubectl logs -n "${1}" "${POD}" -c "${2}"
fi
