#!/bin/bash

HW_DC="
    details-v1 \
    productpage-v1 \
    ratings-v1 \
    reviews-v1 \
    reviews-v2 \
    reviews-v3"

createPolicy() {

echo "Creating policy for $DC_NAME\n"

echo "---
apiVersion: authentication.istio.io/v1alpha1
kind: Policy
metadata:
  name: $DC_NAME-mtls
spec:
  peers:
  - mtls:
      mode: STRICT
  targets:
  - name: $DC_NAME
" | oc apply -n bookinfo -f -

}




for DC_NAME in $HW_DC
do
  createPolicy
  sleep 2
done
