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
# This file is executed to deploy the set of components we want to test integration of
echo "Deploying the SP components to test their integration..."
echo "Step #1: preparing the environement:"
REPO="tng-devops"
echo "    1.a: cloning the $REPO repository..."
git clone "https://github.com/sonata-nfv/$REPO.git"
if [ $? -ne 0 ]
then
  echo >&2 "Cloning https://github.com/sonata-nfv/tng-devops.git failled"
  exit 1
fi
echo "    1.b: changing directory..."
cd $REPO
if [ $? -ne 0 ]
then
  echo >&2 "Changing directory to $DIR failled"
  exit 1
fi
echo "    ...done!"
echo "Step #2: Deploying components:"
ansible-playbook roles/sp.yml -i environments -e "target=pre-int-sp"
if [ $? -ne 0 ]
then
  echo >&2 "Deploying the SP in pre-int failled"
  exit 1
fi
echo "    ...done!"
echo "SP components deployed in pre-integration..."
