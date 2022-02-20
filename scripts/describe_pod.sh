#!/bin/bash

POD=$(kubectl get pods -n "${1}" | grep "${2}" | grep -v 'grep' | awk '{print $1}')

if [[ -n ${POD} ]]; then
    kubectl describe pod -n "${1}" "${POD}"
fi
