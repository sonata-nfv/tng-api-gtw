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
## Variables
INTEGRATION_TESTS_FOLDER="./tests/integration"
FIXTURES_FOLDER="$INTEGRATION_TESTS_FOLDER/fixtures"
TEST_PACKAGE_FILE="5gtango-ns-package-example.tgo"
PRE_INTEGRATION_URL="http://pre-int-sp-ath.5gtango.eu:32002/api/v3"
PACKAGES_PRE_INTEGRATION_URL="$PRE_INTEGRATION_URL/packages"
SERVICES_PRE_INTEGRATION_URL="$PRE_INTEGRATION_URL/services"
FUNCTIONS_PRE_INTEGRATION_URL="$PRE_INTEGRATION_URL/functions"
REQUESTS_PRE_INTEGRATION_URL="$PRE_INTEGRATION_URL/requests"
echo "==================="

# Test package file presence
echo "Testing package file presence..."
echo "PWD is $(pwd)"

if  ! [ -e "$FIXTURES_FOLDER/$TEST_PACKAGE_FILE" ]
then
    echo "Test package file $TEST_PACKAGE_FILE not found in $FIXTURES_FOLDER folder"
    exit 1
fi
echo "    ...done!"

. $INTEGRATION_TESTS_FOLDER/upload_package.sh
. $INTEGRATION_TESTS_FOLDER/download_package.sh
. $INTEGRATION_TESTS_FOLDER/download_service.sh
. $INTEGRATION_TESTS_FOLDER/download_function.sh
#. $INTEGRATION_TESTS_FOLDER/instantiate_service.sh
. $INTEGRATION_TESTS_FOLDER/delete_package.sh
