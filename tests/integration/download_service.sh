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
echo "Dowloading all services..."
AVAILABLE_SERVICES=$(curl -s "$SERVICES_PRE_INTEGRATION_URL")
echo "    AVAILABLE_SERVICES=$AVAILABLE_SERVICES"
if [ "$AVAILABLE_SERVICES" == "[]" ]; then
  echo "There are no services available in the Catalogue"
  exit 1
fi
FIRST_AVAILABLE_SERVICE=$(echo $AVAILABLE_SERVICES | jq '.[0]')
echo "    FIRST_AVAILABLE_SERVICE=$FIRST_AVAILABLE_SERVICE"
SERVICE_UUID=$(echo $FIRST_AVAILABLE_SERVICE | jq -r '.uuid')
echo "    SERVICE_UUID=$SERVICE_UUID"
SERVICE_META_DATA_CODE=$(curl --write-out %{http_code} --silent --output /dev/null "$SERVICES_PRE_INTEGRATION_URL/$SERVICE_UUID")
echo "    SERVICE_META_DATA_CODE=$SERVICE_META_DATA_CODE"
if [ "$SERVICE_META_DATA_CODE" != "200" ]; then
  echo "Service $SERVICE_UUID meta-data query failled with code $PACKAGE_META_DATA_CODE"
  exit 1
fi
echo "    ...SUCCESS downloading service!"
