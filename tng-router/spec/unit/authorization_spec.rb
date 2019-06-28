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

RSpec.describe Authorization do
  #let(:app) { ->(env) { [200, env, "app"] } }
  #let(:app) { ->(env) { [200, env_for('http://help.example.com', {'5gtango.logger' => Logger.new(STDERR)}), "app"] } }
  let(:app)  {double('app')}
  let(:middleware) {described_class.new(app)}
  #subject { described_class.new(app.call(env_for('http://help.example.com', {'5gtango.logger' => Logger.new(STDERR), auth_uri: uri })))}
  subject { described_class.new(app)}
  let(:request) { Rack::MockRequest.new(subject) }
  let(:path) {"/protected"}

  context 'when no role is present, it' do
    it 'fails' do
      env = env_for(path)
      env['5gtango.verbs'] = 'post'
      code, _, _= middleware.call(env)
      expect(code).to eq(403)
    end
  end
  context 'when no verbs are present, it' do
    it 'fails' do
      env = env_for(path)
      env['5gtango.verbs'] = 'post'
      env['5gtango.role'] = 'admin'
      code, _, _= middleware.call(env)
      expect(code).to eq(403)
    end
  end
  
  context 'when verbs are present, but not the one used, it' do
    it 'fails' do
      env = env_for(path)
      env['5gtango.verbs'] = 'post'
      env['5gtango.role'] = 'admin'
      env['REQUEST_METHOD'] = 'GET'
      allow(app).to receive(:call).with(env)
      middleware.call(env)
      expect(app).not_to have_received(:call)
    end
    it 'returns 403' do
      env = env_for(path)
      env['5gtango.verbs'] = 'post'
      env['5gtango.role'] = 'admin'
      env['REQUEST_METHOD'] = 'GET'
      allow(app).to receive(:call).with(env)
      code, _, _ = middleware.call(env)
      expect(code).to eq(403)
    end
  end
  
  context 'when verbs are present, including the one used, it' do
    it 'just falls through' do
      env = env_for(path)
      env['5gtango.verbs'] = 'get'
      env['5gtango.role'] = 'admin'
      env['REQUEST_METHOD'] = 'GET'
      allow(app).to receive(:call).with(env)
      middleware.call(env)
      expect(app).to have_received(:call)
    end
  end  
  def env_for url, opts={}
    Rack::MockRequest.env_for(url, opts)
  end
end
