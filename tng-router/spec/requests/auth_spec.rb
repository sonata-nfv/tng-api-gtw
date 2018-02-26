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
require_relative '../spec_helper'

RSpec.describe Auth, type: :request do 
  let(:app) { ->(env) { [200, env, "app"] } }
  let(:uri) {"http://son-gtkusr:5600/"}
#  let(:auth) {described_class.new(app, auth_uri: 'http://son-gtkusr:5600' )}
  subject { described_class.new(app, auth_uri: uri) }
  let(:request) { Rack::MockRequest.new(subject) }
  let(:post_data) { "Whatever post data" }
  let(:headers) {{'Accept'=>'application/json', 'Authorization'=>'Bearer abc', 'Content-Type'=>'application/json'}}

  it "without any authorization token it just flows" do
    # this would be good for unit tests
    # code, env = subject.call env_for('http://help.example.com')
    # expect(code).to eq(200)
    response = request.post("/some/path", input: post_data)
    expect(response.status).to eq(200)
  end
  it "with invalid authorization token, it fails with 401" do
    response = request.post("/some/path", input: post_data, 'HTTP_AUTHORIZATION' => 'whatever')
    stub_request(:post, uri).with(headers: headers).to_return(status: 401, body: "", headers: {})
    expect(response.status).to eq(400)
  end
  context "with valid authorization token" do
    let(:response) {request.post("/some/path", input: post_data, 'HTTP_AUTHORIZATION' => 'bearer abc')}
    let(:user_name) {'user_one'}
    let(:user) {{ sub:'no matter', name: 'same', preferred_username: user_name, email: user_name+'@example.com'}}
    it "fails with 401 if token is not active" do
      stub_request(:post, uri).with(headers: headers).to_return(status: 401, body: "", headers: {})
      expect(response.status).to eq(401)
    end
    it "fails with 404 if user is not found" do
      stub_request(:post, uri).with(headers: headers).to_return(status: 404, body: "", headers: {})
      expect(response.status).to eq(404)
    end
    it "passes (with 200) if token is active, giving user name" do
      stub_request(:post, uri).with(headers: headers).to_return(status: 201, body: user.to_json, headers: {})
      expect(response.headers['5gtango.user.name']).to eq(user_name)
      expect(response.status).to eq(200)
    end
  end
  
  def env_for url, opts={}
    Rack::MockRequest.env_for(url, opts)
  end
end
