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
## Variables
FIXTURES_FOLDER="./tests/integration/fixtures"
TEST_PACKAGE_FILE="5gtango-ns-package-example.tgo"
PRE_INTEGRATION_URL="http://pre-int-sp-ath.5gtango.eu:32002/api/v3"
PACKAGES_PRE_INTEGRATION_URL="$PRE_INTEGRATION_URL/packages"

# Test package file presence
echo "Testing package file presence..."
echo "PWD is $(pwd)"

if  ! [ -e "$FIXTURES_FOLDER/$TEST_PACKAGE_FILE" ]
then
    echo "Test package file $TEST_PACKAGE_FILE not found in $FIXTURES_FOLDER folder"
    exit 1
fi
echo "    ...done!"

# Testing package file upload
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
TIMES_TO_RUN=50
while [ $TIMES_TO_RUN -ne 0 ]
do
  TIMES_TO_RUN=$((TIMES_TO_RUN-1))
  echo "Getting package status..."
  PACKAGE_PROCESS_DATA=$(curl -qfsS "$PACKAGES_PRE_INTEGRATION_URL/status/$PACKAGE_PROCESS_UUID")
  echo "    PACKAGE_PROCESS_DATA=$PACKAGE_PROCESS_DATA"
  PACKAGE_PROCESS_STATUS=$(echo $PACKAGE_PROCESS_DATA | jq -r '.status')
  echo "    PACKAGE_PROCESS_STATUS=$PACKAGE_PROCESS_STATUS"
  if [ "$PACKAGE_PROCESS_STATUS" == "running" ]; then
    echo "Package file $FIXTURES_FOLDER/$TEST_PACKAGE_FILE processing still running..."
    sleep 10
    continue
  fi
  if [ "$PACKAGE_PROCESS_STATUS" == "failed" ]; then
    ERROR=$(echo $PACKAGE_PROCESS_DATA | jq -r '.package_metadata.error')
    echo "Package file $FIXTURES_FOLDER/$TEST_PACKAGE_FILE processing failled with error '$ERROR'"
    exit 1
  fi
  if [ $PACKAGE_PROCESS_STATUS == "success" ]; then 
    break
  fi
done
echo "    PACKAGE_PROCESS_STATUS=$PACKAGE_PROCESS_STATUS"
if [ "$PACKAGE_PROCESS_STATUS" != "success" ]; then
  echo "Package file $FIXTURES_FOLDER/$TEST_PACKAGE_FILE processing failled with $PACKAGE_PROCESS_DATA"
  exit 1
fi
echo "Getting package uuid..."
PACKAGE_UUID=$(echo $PACKAGE_PROCESS_DATA | jq -r '.package_id')
echo "    PACKAGE_UUID=$PACKAGE_UUID"
if [ -z "$PACKAGE_UUID" ]; then
  echo "Package file $FIXTURES_FOLDER/$TEST_PACKAGE_FILE upload failled with no package UUID"
  exit 1
fi
echo "Getting package meta-data..."
PACKAGE_META_DATA_CODE=$(curl --write-out %{http_code} --silent --output /dev/null "$PACKAGES_PRE_INTEGRATION_URL/$PACKAGE_UUID")
echo "    PACKAGE_META_DATA_CODE=$PACKAGE_META_DATA_CODE"
if [ "$PACKAGE_META_DATA_CODE" != "200" ]; then
  echo "Package file $FIXTURES_FOLDER/$TEST_PACKAGE_FILE meta-data download failled with code $PACKAGE_META_DATA_CODE"
  exit 1
fi
echo "Getting package file..."
echo "    ...not done yet!"
echo "Deleting the package..."
PACKAGE_META_DATA_CODE=$(curl -X DELETE --write-out %{http_code} --silent --output /dev/null "$PACKAGES_PRE_INTEGRATION_URL/$PACKAGE_UUID")
echo "\tPACKAGE_META_DATA_CODE=$PACKAGE_META_DATA_CODE"
if [ "$PACKAGE_META_DATA_CODE" != "204" ]; then
  echo "Package file $FIXTURES_FOLDER/$TEST_PACKAGE_FILE meta-data delete failled with code $PACKAGE_META_DATA_CODE"
  exit 1
fi
echo "Verify that package has been deleted..."
PACKAGE_META_DATA_CODE=$(curl --write-out %{http_code} --silent --output /dev/null "$PACKAGES_PRE_INTEGRATION_URL/$PACKAGE_UUID")
echo "    PACKAGE_META_DATA_CODE=$PACKAGE_META_DATA_CODE"
if [ "$PACKAGE_META_DATA_CODE" != "404" ]; then
  echo "Package file $FIXTURES_FOLDER/$TEST_PACKAGE_FILE meta-data delete failled with code $PACKAGE_META_DATA_CODE"
  exit 1
fi
echo "    ...done!"
