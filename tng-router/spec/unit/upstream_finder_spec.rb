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

RSpec.describe UpstreamFinder do
  let(:app) { ->(env) { [200, env, "app"] } }
  let(:base_path) {''}
  context 'Service Platform' do
    let(:paths)     {{
      :"/api/v3/packages(/?|/*)"=>{:site=>"http://tng-gtk-common:5000/packages", :verbs=>["get", "post"]}, 
      :"/api/v3/services(/?|/*)"=>{:site=>"http://tng-gtk-common:5000/services"}, 
      :"/api/v3/functions(/?|/*)"=>{:site=>"http://tng-gtk-common:5000/functions"}, 
      :"/api/v3/records(/?|/*)"=>{:site=>"http://tng-gtk-common:5000/records"}, 
      :"/slices(/?|/*)"=>{:site=>"http://tng-slice-mngr:5998", :verbs=>["get", "post", "delete"]}, 
      :"/policies(/?|/*)"=>{:site=>"http://tng-policy-mngr:8081"}, 
      :"/slas(/?|/*)"=>{:site=>"http://tng-sla-mgmt:8080"}}}
    let(:middleware) { described_class.new(app, base_path: base_path, paths: paths) }
  
    it "processes GET requests" do
      env = env_for('http://example.com/api/v3/packages/status/123', request_method: 'GET', 
      '5gtango.sink_path'=>'http://tng-gtk-common:5000/packages', '5gtango.logger'=> Logger.new(STDERR))
      code, env = middleware.call(env)
      expect(code).to eq(200)
      expect(env['5gtango.sink_path']).to eq('http://tng-gtk-common:5000/packages/status/123')
    end
  
    describe '.build_path' do
      it 'is ok for /packages' do
        env = env_for('http://example.com/api/v3/packages', request_method: 'GET', '5gtango.logger'=> Logger.new(STDERR))
        expect(middleware.build_path(Rack::Request.new(env))).to eq 'http://tng-gtk-common:5000/packages'
      end
      it 'is ok for /packages/' do
        env = env_for('http://example.com/api/v3/packages/', request_method: 'GET', '5gtango.logger'=> Logger.new(STDERR))
        expect(middleware.build_path(Rack::Request.new(env))).to eq 'http://tng-gtk-common:5000/packages'
      end
      it 'is ok for /packages?page_number=0&page_size=100' do
        env = env_for('http://example.com/api/v3/packages?page_number=0&page_size=100', request_method: 'GET', '5gtango.logger'=> Logger.new(STDERR))
        expect(middleware.build_path(Rack::Request.new(env))).to eq 'http://tng-gtk-common:5000/packages?page_number=0&page_size=100'
      end
      it 'is ok for /packages/status/:uuid' do
        env = env_for('http://example.com/api/v3/packages/status/123', request_method: 'GET', '5gtango.logger'=> Logger.new(STDERR))
        expect(middleware.build_path(Rack::Request.new(env))).to eq 'http://tng-gtk-common:5000/packages/status/123'
      end
    end
  end
  
  context 'V&V Platform' do
    let(:paths)     {{
      :"/api/v3/tests/plans(/?|/*)"=>{:site=>"http://tng-gtk-vnv:5000/tests/plans", :verbs=>["get", "post", "options"]}, 
      :"/api/v3/tests(/?|/*)"=>{:site=>"http://tng-gtk-vnv:5000/tests", :verbs=>["get", "options"]}
      }}
    let(:middleware) { described_class.new(app, base_path: base_path, paths: paths) }
    it 'is ok for POSTing /tests/plans' do
      env = env_for('http://example.com/api/v3/tests/plans', request_method: 'POST', '5gtango.logger'=> Logger.new(STDERR))
      expect(middleware.build_path(Rack::Request.new(env))).to eq 'http://tng-gtk-vnv:5000/tests/plans'
    end
    it 'is ok for GETing /tests/plans' do
      env = env_for('http://example.com/api/v3/tests/plans', request_method: 'GET', '5gtango.logger'=> Logger.new(STDERR))
      expect(middleware.build_path(Rack::Request.new(env))).to eq 'http://tng-gtk-vnv:5000/tests/plans'
    end
    it 'is ok for GETing /tests/plans' do
      env = env_for('http://example.com/api/v3/tests/descriptors', request_method: 'GET', '5gtango.logger'=> Logger.new(STDERR))
      expect(middleware.build_path(Rack::Request.new(env))).to eq 'http://tng-gtk-vnv:5000/tests/descriptors'
    end
    it 'is ok for GETing /tests/plans' do
      env = env_for('http://example.com/api/v3/tests/results', request_method: 'GET', '5gtango.logger'=> Logger.new(STDERR))
      expect(middleware.build_path(Rack::Request.new(env))).to eq 'http://tng-gtk-vnv:5000/tests/results'
    end
  end
  def env_for url, opts={}
    Rack::MockRequest.env_for(url, opts)
  end
end