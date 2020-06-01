#!/bin/bash

HW_DeploymentConfigs="
    details-v1 \
    productpage-v1 \
    ratings-v1 \
    reviews-v1 \
    reviews-v2 \
    reviews-v3"



configureProbes() {

oc patch dc $DC_NAME --type='json' -p '[{"op": "remove", "path": "/spec/template/spec/containers/0/livenessProbe/httpGet"}, {"op": "add", "path": "/spec/template/spec/containers/0/livenessProbe", "value": { "exec": { "command" : ["curl", "http://127.0.0.1:8080/actuator/health"]}, "initialDelaySeconds": 30, "timeoutSeconds": 3, "periodSeconds": 30, "successThreshold": 1, "failureThreshold": 3}}, {"op": "remove", "path": "/spec/template/spec/containers/0/readinessProbe/httpGet"}, {"op": "add", "path": "/spec/template/spec/containers/0/readinessProbe", "value": { "exec": { "command" : ["curl", "http://127.0.0.1:8080/actuator/health"]}, "initialDelaySeconds": 30, "timeoutSeconds": 3, "periodSeconds": 30, "successThreshold": 1, "failureThreshold": 3}}]' -n bookinfo



}



for DC_NAME in HW_DeployentConfigs
do 
  configureProbes
done
