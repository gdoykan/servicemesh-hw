#!/bin/bash

HW_DeploymentConfigs="
    details-v1 \
    productpage-v1 \
    ratings-v1 \
    reviews-v1 \
    reviews-v2 \
    reviews-v3"

# 5.1 Add bookinfo project to service mesh member roll
echo "Creating servicemesh member roll"
echo "apiVersion: maistra.io/v1
kind: ServiceMeshMemberRoll
metadata:
  name: default
spec:
  members:
    - bookinfo" | oc create -n bookretail-istio-system -f -
sleep 10

### 5.2 Add auto injection annotation to bookinfo deployments

function injectAndResume() {

echo -en "\n\nInjecting istio sidecar annotation into DC: $DC_NAME\n"
oc patch deployment $DC_NAME -p '{"spec":{"template":{"metadata":{"annotations":{"sidecar.istio.io/inject":"true"}}}}}' -n bookinfo
sleep 2

}

###6.2 Create Policy for bookinfo deployments, set to Permissive for now

function createPolicy() { 
echo "Creating policy for $DC_NAME\n"

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

#6.2 Enable Strict mtls policy
function enableStrict() {
oc patch policy $DC_NAME-mtls --type='json' -p '[{"op":"replace","path":"/spec/peers/0/mtls/mode", "value": "STRICT"}]' -n bookinfo

}

for DC_NAME in $HW_DeploymentConfigs;
do
  injectAndResume
  sleep 2
done
sleep 10

for DC_NAME in $HW_DeploymentConfigs;
do
  createPolicy
  sleep 2
done

sleep 5
#6.3 Define Ingress gateway for application
oc apply -f templates/bookinfo-gateway.yaml -n bookinfo
sleep 5
#6.3 Apply destination rules
oc apply -f templates/destination-rules-mtls -n bookinfo
sleep 10

for DC_NAME in $HW_DeploymentConfigs;
do
  enableStrict
  sleep 2
done

echo "Service Mesh config DONE"
