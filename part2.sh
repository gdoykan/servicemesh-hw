#!/bin/bash

HW_DeploymentConfigs="
    details-v1 \
    productpage-v1 \
    ratings-v1 \
    reviews-v1 \
    reviews-v2 \
    reviews-v3"

SUBDOMAIN_BASE = cluster-1e4c.1e4c.sandbox302.opentlc.com



configureProbes() {
oc patch dc $DC_NAME --type='json' -p '[{"op": "remove", "path": "/spec/template/spec/containers/0/livenessProbe/httpGet"}, {"op": "add", "path": "/spec/template/spec/containers/0/livenessProbe", "value": { "exec": { "command" : ["curl", "http://127.0.0.1:8080/actuator/health"]}, "initialDelaySeconds": 30, "timeoutSeconds": 3, "periodSeconds": 30, "successThreshold": 1, "failureThreshold": 3}}, {"op": "remove", "path": "/spec/template/spec/containers/0/readinessProbe/httpGet"}, {"op": "add", "path": "/spec/template/spec/containers/0/readinessProbe", "value": { "exec": { "command" : ["curl", "http://127.0.0.1:8080/actuator/health"]}, "initialDelaySeconds": 30, "timeoutSeconds": 3, "periodSeconds": 30, "successThreshold": 1, "failureThreshold": 3}}]' -n bookinfo
}

createPolicy(){

echo "---
apiVersion: authentication.istio.io/v1alpha1
kind: Policy
metadata:
  name: $DC_NAME-mtls
spec:
  peers:
  - mtls:
      mode: PERMISSIVE
  targets:
  - name: $DC_NAME
" | oc create -n bookinfo -f -

}

createDestinationRule(){

echo "---
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: $DC_NAME-client-mtls
spec:
  host: $DC_NAME.bookinfo.svc.cluster.local
  trafficPolicy:
    tls:
      mode: ISTIO_MUTUAL
" | oc create -n bookinfo -f -

}

createVirtualService(){

echo "---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: $DC_NAME-virtualservice
spec:
  hosts:
  - $DC_NAME.bookinfo.apps.$SUBDOMAIN_BASE
  gateways:
  - erd-wildcard-gateway.bookretail-istio-system.svc.cluster.local
  http:
  - match:
    - uri:
        prefix: /
    route:
    - destination:
        port:
          number: 8080
        host: $DC_NAME.bookinfo.svc.cluster.local
" | oc create -n bookinfo -f -

}

createRoute() {

echo "---
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  annotations:
    openshift.io/host.generated: \"true\"
  labels:
    app: incident-service
  name: incident-service-gateway
spec:
  host: $DC_NAME.bookinfo.apps.$SUBDOMAIN_BASE
  port:
    targetPort: https
  tls:
    termination: passthrough
  to:
    kind: Service
    name: istio-ingressgateway
    weight: 100
  wildcardPolicy: None
"

}



for DC_NAME in HW_DeployentConfigs
do
  configureProbes
  sleep 2
  createPolicy
done
