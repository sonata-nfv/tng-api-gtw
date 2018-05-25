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

RSpec.describe Getter do
  let(:app) { ->(env) { [200, env, "app"] } }
  let(:middleware) { Getter.new(app) }
  let(:request_headers) {{'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'5GTANGO Gatekeeper'}}
  it "processes GET requests" do
    allow(Rack::NullLogger).to receive(:info)
    allow(Rack::NullLogger).to receive(:debug) # 'Content-Type'=>'application/json', 
    stub_request(:get, "http://example.com/").to_return(status: 200, body: "", headers: {})
    #  with(headers: request_headers)
    code, env = middleware.call env_for('http://example.com', request_method: 'GET', '5gtango.sink_path'=>'http://example.com')
    
    expect(code).to eq(200)
  end

  def env_for url, opts={}
    Rack::MockRequest.env_for(url, opts)
  end
end