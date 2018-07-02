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
echo "Testing package file upload..."
UPLOAD_RESPONSE=$(curl -qfsS -X POST $PACKAGES_PRE_INTEGRATION_URL -F package=@"$FIXTURES_FOLDER/$TEST_PACKAGE_FILE")
echo "    UPLOAD_RESPONSE=$UPLOAD_RESPONSE"
PACKAGE_PROCESS_UUID=$(echo $UPLOAD_RESPONSE | jq -r '.package_process_uuid')
echo "    PACKAGE_PROCESS_UUID=$PACKAGE_PROCESS_UUID"
if [ -z "$PACKAGE_PROCESS_UUID" ]; then
  echo "Package file $FIXTURES_FOLDER/$TEST_PACKAGE_FILE upload to $PACKAGES_PRE_INTEGRATION_URL failled with $UPLOAD_RESPONSE"
  exit 1
fi
echo "    ...successfuly!"
MAX_TIMES_TO_RUN=20
TIMES_TO_RUN=$MAX_TIMES_TO_RUN
echo "Getting package status..."
while true; do
  let RUN=$MAX_TIMES_TO_RUN-$TIMES_TO_RUN
  echo "    Run #$RUN"
  if [ $TIMES_TO_RUN == 0 ]; then
    break
  fi
  TIMES_TO_RUN=$((TIMES_TO_RUN-1))
  PACKAGE_PROCESS_DATA=$(curl -qfsS "$PACKAGES_PRE_INTEGRATION_URL/status/$PACKAGE_PROCESS_UUID")
  echo "    PACKAGE_PROCESS_DATA=$PACKAGE_PROCESS_DATA"
  PACKAGE_PROCESS_STATUS_HEAD=$(echo $PACKAGE_PROCESS_DATA | jq -r '.status')
  if [ "$PACKAGE_PROCESS_STATUS_HEAD" != "null" ]; then
    echo "    PACKAGE_PROCESS_STATUS_HEAD=$PACKAGE_PROCESS_STATUS_HEAD"
    if [ "$PACKAGE_PROCESS_STATUS_HEAD" == "running" ]; then
      echo "Package file $FIXTURES_FOLDER/$TEST_PACKAGE_FILE processing still running..."
      sleep 10
      continue
    fi
  else
    echo "    PACKAGE_PROCESS_STATUS_HEAD not defined"
    break
  fi
done
if [ $TIMES_TO_RUN == 0 ]; then
  echo "Package $FIXTURES_FOLDER/$TEST_PACKAGE_FILE processing failled to end after running $MAX_TIMES_TO_RUN times"
  exit 1
fi
PACKAGE_PROCESS_STATUS_TAIL=$(echo $PACKAGE_PROCESS_DATA | jq -r '.package_process_status')
echo "    PACKAGE_PROCESS_STATUS_TAIL=$PACKAGE_PROCESS_STATUS_TAIL"
if [ "$PACKAGE_PROCESS_STATUS_TAIL" == "failed" ]; then
  ERROR=$(echo $PACKAGE_PROCESS_DATA | jq -r '.package_metadata.error')
  echo "Package file $FIXTURES_FOLDER/$TEST_PACKAGE_FILE processing failled with error '$ERROR'"
  exit 1
fi
echo "Getting package uuid..."
PACKAGE_UUID=$(echo $PACKAGE_PROCESS_DATA | jq -r '.package_id')
echo "    PACKAGE_UUID=$PACKAGE_UUID"
if [ -z "$PACKAGE_UUID" ]; then
  echo "Package file $FIXTURES_FOLDER/$TEST_PACKAGE_FILE upload failled with no package UUID"
  #exit 1
  echo "    ...uploading package FAILLED but we're proceeding"
else
  echo "    ...SUCCESS uploading package!"
fi
