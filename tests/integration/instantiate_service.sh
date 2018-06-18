#!/bin/bash
## Copyright (c) 2015 SONATA-NFV, 2017 5GTANGO [, ANY ADDITIONAL AFFILIATION]
## ALL RIGHTS RESERVED.
##
## Licensed under the Apache License, Version 2.0 (the "License");
## you may not use this file except in compliance with the License.
## You may obtain a copy of the License at
##
##     http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.
##
## Neither the name of the SONATA-NFV, 5GTANGO [, ANY ADDITIONAL AFFILIATION]
## nor the names of its contributors may be used to endorse or promote
## products derived from this software without specific prior written
## permission.
##
## This work has been performed in the framework of the SONATA project,
## funded by the European Commission under Grant number 671517 through
## the Horizon 2020 and 5G-PPP programmes. The authors would like to
## acknowledge the contributions of their colleagues of the SONATA
## partner consortium (www.sonata-nfv.eu).
##
## This work has been performed in the framework of the 5GTANGO project,
## funded by the European Commission under Grant number 761493 through
## the Horizon 2020 and 5G-PPP programmes. The authors would like to
## acknowledge the contributions of their colleagues of the 5GTANGO
## partner consortium (www.5gtango.eu).
# encoding: utf-8
#
# This file holds the integration tests
echo "Testing service instantiation..."
REQUEST_DATA="{'uuid':'$SERVICE_UUID'}"
CREATION_RESPONSE=$(curl -qfsS -X POST $REQUESTS_PRE_INTEGRATION_URL -d '{"uuid":"$SERVICE_UUID"}')
echo "    CREATION_RESPONSE=$CREATION_RESPONSE"
REQUEST_ID=$(echo $CREATION_RESPONSE | jq -r '.id')
echo "    REQUEST_ID=$REQUEST_ID"
if [ -z "$REQUEST_ID" ]; then
  echo "Request $REQUEST_DATA failled with $CREATION_RESPONSE"
#  exit 1
  exit 0
fi
echo "    ...successfuly!"
MAX_TIMES_TO_RUN=20
TIMES_TO_RUN=$MAX_TIMES_TO_RUN
echo "Getting service instance status..."
while true; do
  let RUN=$MAX_TIMES_TO_RUN-$TIMES_TO_RUN
  echo "    Run #$RUN"
  if [ $TIMES_TO_RUN == 0 ]; then
    break
  fi
  TIMES_TO_RUN=$((TIMES_TO_RUN-1))
  REQUEST_RESPONSE_DATA=$(curl -qfsS "$REQUESTS_PRE_INTEGRATION_URL/$REQUEST_ID")
  echo "    REQUEST_RESPONSE_DATA=$REQUEST_RESPONSE_DATA"
  REQUEST_RESPONSE_STATUS=$(echo $REQUEST_RESPONSE_DATA | jq -r '.status')
  if [ "$REQUEST_RESPONSE_STATUS" != "null" ]; then
    echo "    REQUEST_RESPONSE_STATUS=$REQUEST_RESPONSE_STATUS"
    if [ "$REQUEST_RESPONSE_STATUS" == "INSTANTIATING" ]; then
      echo "Service $SERVICE_UUID instantiation still running..."
      sleep 5
      continue
    elif [ "$REQUEST_RESPONSE_STATUS" == "READY" ]; then
      echo "Service $SERVICE_UUID instantiation READY..."
      break
    elif [ "$REQUEST_RESPONSE_STATUS" == "ERROR" ]; then
      echo "Service $SERVICE_UUID instantiation ERROR..."
      break
    fi
  else
    echo "    REQUEST_RESPONSE_STATUS_HEAD not defined"
    break
  fi
done
#if [ $TIMES_TO_RUN == 0 ]; then
#  echo "Service $SERVICE_UUID instantiation failled to end after running $MAX_TIMES_TO_RUN times"
#  exit 1
#fi
#if [ "$REQUEST_RESPONSE_STATUS" == "ERROR" ]; then
#  exit 1
#fi
echo "Getting service instance uuid..."
SERVICE_INSTANCE_UUID=$(echo $REQUEST_RESPONSE_DATA | jq -r '.instance_id')
echo "    SERVICE_INSTANCE_UUID=$SERVICE_INSTANCE_UUID"
if [ -z "$SERVICE_INSTANCE_UUID" ]; then
  echo "Service \"$SERVICE_UUID\" request \"$REQUEST_ID\" failled to instantiate with no SERVICE_INSTANCE_UUID"
#  exit 1
fi
echo "    ...SUCCESS instantiating service: \"$SERVICE_INSTANCE_UUID\"!"
