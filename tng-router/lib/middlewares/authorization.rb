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
require 'rack'
require 'tng/gtk/utils/logger'
require_relative '../utils'

class Authorization
  LOGGER=Tng::Gtk::Utils::Logger
  LOGGED_COMPONENT=self.name
  
  def initialize(app, options={})
    @app, @paths = app, options[:paths]
  end

  def call(env)
    content = {'Content-Type'=>'application/json'}
    return([403, content, [{error: "Forbidden: user role must be defined"}.to_json]]) unless (env.key?('5gtango.role') && env['5gtango.role'] != '')
    if is_authorized?(env)
      return @app.call(env)
    else
      return([403, content, [{error: "Forbidden: user role #{env['5gtango.role']} is not authorized to #{env['REQUEST_METHOD']} from #{env['REQUEST_PATH']}"}.to_json]])
    end
  end
  
  private
  def is_authorized?(env)
    env['5gtango.verbs'].split(',').include?(env['REQUEST_METHOD'].downcase)
  end
end

