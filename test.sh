#!/bin/bash

ER_DeploymentConfigs="
        $ERDEMO_USER-incident-service \
        $ERDEMO_USER-incident-priority-service \
        $ERDEMO_USER-mission-service \
        $ERDEMO_USER-responder-service \
        $ERDEMO_USER-process-service \
        $ERDEMO_USER-process-viewer \
        $ERDEMO_USER-disaster-simulator \
        $ERDEMO_USER-emergency-console \
        $ERDEMO_USER-responder-simulator"


for DC_NAME in $ER_DeploymentConfigs;
do
  echo "you did it for $DC_NAME"
done


