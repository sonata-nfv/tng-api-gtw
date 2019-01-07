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
# frozen_string_literal: true
# encoding: utf-8
require_relative '../spec_helper'
require 'jwt'

RSpec.describe Authentication do
  #let(:app) { ->(env) { [200, env, "app"] } }
  #let(:app) { ->(env) { [200, env_for('http://help.example.com', {'5gtango.logger' => Logger.new(STDERR)}), "app"] } }
  let(:app)  {double('app')}
  let(:middleware) {described_class.new(app)}
  let(:uri) {"http://son-gtkusr:5600/"}
  #subject { described_class.new(app.call(env_for('http://help.example.com', {'5gtango.logger' => Logger.new(STDERR), auth_uri: uri })))}
  subject { described_class.new(app)}
  let(:request) { Rack::MockRequest.new(subject) }
  let(:post_data) { "Whatever post data" }
  let(:headers) {{'Accept'=>'application/json', 'Authorization'=>'Bearer abc', 'Content-Type'=>'application/json'}}
  let(:path) {"/protected"}
  let(:time) {Time.now.utc}
  let(:valid_token) {JWT.encode({username:'paco', email:"paco@paco", endpoints: [{endpoint:path, verbs:"get,post,put"}, {endpoint:"services", verbs:"get,post"}], login_time:time.to_s, expiration_time:(time+10000).to_s},'my_secret', 'HS256')}
  let(:expired_token) {'eyJhbGciOiJIUzI1NiJ9.eyJ1c2VybmFtZSI6InBhY28iLCJlbWFpbCI6InBhY29AcGFjbyIsImxvZ2luX3RpbWUiOiIyMDE4LTEyLTAzIDEyOjA1OjU0ICswMTAwIiwiZXhwaXJhdGlvbl90aW1lIjoiMjAxOC0xMi0wMyAxMzowNTo1NCArMDEwMCJ9.s4t5ePyT0FXYDUS28X9DM5_HfA5tk8VgpvlBxoTTDc8'}

  context 'without Authorization HTTP header defined' do
    it 'just falls through' do
      env = env_for(path)
      env['HTTP_AUTHORIZATION'] = ''
      allow(app).to receive(:call).with(env)
      middleware.call(env)
      expect(app).to have_received(:call)
    end
  end

  context 'with Authorization HTTP header defined' do
    
    it 'but it is not a bearer, fails' do
      env = env_for(path)
      env['HTTP_AUTHORIZATION'] = 'wrong kind-of-token'
      status, _, _ = middleware.call(env)
      expect(status).to eq(400)
    end
    it 'and bearer like, but invalid' do
      env = env_for(path)
      env['HTTP_AUTHORIZATION'] = 'bearer kind-of-token'
      status, _, _ = middleware.call(env)
      expect(status).to eq(400)
    end
    context 'and bearer like, valid' do
      it 'but outdated' do
        env = env_for(path)
        env['HTTP_AUTHORIZATION'] = 'bearer '+expired_token
        status, _, _ = middleware.call(env)
        expect(status).to eq(401)
      end
      it 'and up-to-date' do
        env = env_for(path, 'HTTP_AUTHORIZATION'=>'bearer '+valid_token, 'PATH_INFO'=>path)
        allow(app).to receive(:call).with(env).and_return([200, {}, ['Ok']])
        status, h, b = middleware.call(env)
        expect(status).to eq(200)
      end
    end
  end
  
  def env_for url, opts={}
    Rack::MockRequest.env_for(url, opts)
  end
end
