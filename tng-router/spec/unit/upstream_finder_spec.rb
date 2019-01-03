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
  describe 'Service Platform' do
    let(:paths)     {{
      :"/api/v3/packages(/?|/*)"=>{:site=>"http://tng-gtk-common:5000/packages", :verbs=>["get", "post"]}, 
      :"/api/v3/services(/?|/*)"=>{:site=>"http://tng-gtk-common:5000/services"}, 
      :"/api/v3/functions(/?|/*)"=>{:site=>"http://tng-gtk-common:5000/functions"}, 
      :"/api/v3/records(/?|/*)"=>{:site=>"http://tng-gtk-common:5000/records"}, 
      :"/slices(/?|/*)"=>{:site=>"http://tng-slice-mngr:5998", :verbs=>["get", "post", "delete"]}, 
      :"/policies(/?|/*)"=>{:site=>"http://tng-policy-mngr:8081"}, 
      :"/slas(/?|/*)"=>{:site=>"http://tng-sla-mgmt:8080"},
      :"/api/v3/users/sessions(/?|/*)"=>{
        site: "http://tng-gtk-usr:4567/login",
        verbs: [ :post ]
      },
      :"/api/v3/users/permissions(/?|/*)"=>{
        site: "http://tng-gtk-usr:4567/endpoints",
        verbs: [ :get, :post, :options, :delete ],
        auth: true
      },
      :"/api/v3/users(/?|/*)"=>{
        site: "http://tng-gtk-usr:4567/users",
        verbs: { get: 'auth', post: nil, options: 'auth', delete: 'auth' }
      }
    }}
    let(:middleware) { described_class.new(app, base_path: base_path, paths: paths) }
  
    describe '.call' do
      let(:paths) {{
        :"/api/v3/users(/?|/*)"=>{
          site: "http://tng-gtk-usr:4567/users",
          verbs: { get: 'auth', post: nil }
        }
      }}
      let(:middleware) { described_class.new(app, base_path: base_path, paths: paths) }
      it 'fails for unacceptable methods' do
        env = env_for 'http://example.com/api/v3/users'
        env['REQUEST_METHOD']='PUT'
        status, _, _ = middleware.call(env)
        expect(status).to eq(404)
      end
      it 'succeeds for acceptable methods' do
        env = env_for 'http://example.com/api/v3/users'
        env['REQUEST_METHOD']='POST'
        status, _, _ = middleware.call(env)
        expect(status).to eq(200)
      end
      context 'without authentication' do
        it 'fails for those endpoints that need it' do
          env = env_for 'http://example.com/api/v3/users'
          env['REQUEST_METHOD']='GET'
          status, _, _ = middleware.call(env)
          expect(status).to eq(403)
        end
        it 'succeeds for those endpoints that do not need it' do
          env = env_for 'http://example.com/api/v3/users'
          env['REQUEST_METHOD']='POST'
          status, _, _ = middleware.call(env)
          expect(status).to eq(200)
        end
      end
      context 'with authentication' do
        it 'succeeds for those endpoints that need it' do
          env = env_for 'http://example.com/api/v3/users'
          env['REQUEST_METHOD']='GET'
          env['5gtango.user.name']='jose'
          status, _, _ = middleware.call(env)
          expect(status).to eq(200)
        end
        it 'also succeeds for those endpoints that do not need it' do
          env = env_for 'http://example.com/api/v3/users'
          env['REQUEST_METHOD']='POST'
          env['5gtango.user.name']='jose'
          status, _, _ = middleware.call(env)
          expect(status).to eq(200)
        end
      end
    end

    it "processes GET requests" do
      env = env_for('http://example.com/api/v3/packages/status/123', request_method: 'GET', '5gtango.sink_path'=>'http://tng-gtk-common:5000/packages')
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
      it 'is ok for GETing /api/v3/users' do
        env = env_for('http://example.com/api/v3/users', request_method: 'GET', '5gtango.user.token'=>'123', '5gtango.user.email'=>'j@j.c', '5gtango.user.name'=>'jose')
        expect(middleware.build_path(Rack::Request.new(env))).to eq 'http://tng-gtk-usr:4567/users'
      end
      it 'is ok for POSTing /api/v3/users' do
        env = env_for('http://example.com/api/v3/users')
        env['REQUEST_METHOD']= 'POST'
        expect(middleware.build_path(Rack::Request.new(env))).to eq 'http://tng-gtk-usr:4567/users'
      end
      it 'raises exception for non-authorized methods' do
        env = env_for('http://example.com/api/v3/users')
        env['REQUEST_METHOD']= 'PUT'
        expect {middleware.build_path(Rack::Request.new(env))}.to raise_exception(Exception)
      end
      it 'is ok for POSTing /api/v3/users/sessions' do
        env = env_for('http://example.com/api/v3/users/sessions')
        env['REQUEST_METHOD']= 'POST'
        expect(middleware.build_path(Rack::Request.new(env))).to eq 'http://tng-gtk-usr:4567/login'
      end
      it 'is ok for POSTing /api/v3/users/permissions' do
        env = env_for('http://example.com/api/v3/users/permissions')
        env['REQUEST_METHOD']= 'POST'
        env['5gtango.user.name']='jose'
        expect(middleware.build_path(Rack::Request.new(env))).to eq 'http://tng-gtk-usr:4567/endpoints'
      end
    end
  end
  
  describe 'V&V Platform' do
    let(:paths)     {{
      :"/api/v3/tests/plans(/?|/*)"=>{:site=>"http://tng-gtk-vnv:5000/plans", :verbs=>["get", "post", "options"]}, 
      :"/api/v3/tests(/?|/*)"=>{:site=>"http://tng-gtk-vnv:5000", :verbs=>["get", "options"]}
      }}
    let(:middleware) { described_class.new(app, base_path: base_path, paths: paths) }
    it 'is ok for POSTing /tests/plans' do
      env = env_for('http://example.com/api/v3/tests/plans', request_method: 'POST', '5gtango.logger'=> Logger.new(STDERR))
      expect(middleware.build_path(Rack::Request.new(env))).to eq 'http://tng-gtk-vnv:5000/plans'
    end
    it 'is ok for GETing /tests/plans' do
      env = env_for('http://example.com/api/v3/tests/plans', request_method: 'GET', '5gtango.logger'=> Logger.new(STDERR))
      expect(middleware.build_path(Rack::Request.new(env))).to eq 'http://tng-gtk-vnv:5000/plans'
    end
    it 'is ok for GETing /tests/descriptors' do
      env = env_for('http://example.com/api/v3/tests/descriptors', request_method: 'GET', '5gtango.logger'=> Logger.new(STDERR))
      expect(middleware.build_path(Rack::Request.new(env))).to eq 'http://tng-gtk-vnv:5000/descriptors'
    end
    it 'is ok for GETing /tests/results' do
      env = env_for('http://example.com/api/v3/tests/results', request_method: 'GET', '5gtango.logger'=> Logger.new(STDERR))
      expect(middleware.build_path(Rack::Request.new(env))).to eq 'http://tng-gtk-vnv:5000/results'
    end
  end
  def env_for url, opts={}
    Rack::MockRequest.env_for(url, opts)
  end
end