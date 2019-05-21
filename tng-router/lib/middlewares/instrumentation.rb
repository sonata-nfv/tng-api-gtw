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
require_relative '../utils'
require_relative '../metrics'
require 'tng/gtk/utils/logger'

class Instrumentation
  LOGGER=Tng::Gtk::Utils::Logger
  LOGGED_COMPONENT=self.name
  include Utils
  
  def initialize(app, options= {})
    @app = app
  end

  def call(env)
    began_at = Time.now
    msg = '#call'
    status, headers, body = @app.call env

    headers['X-Timing'] = (Time.now - began_at).to_f.to_s
    LOGGER.debug(component:LOGGED_COMPONENT, operation:msg, message:"Finishing with status #{status}")
    labels = {status: status, method: env['REQUEST_METHOD'].downcase, host: env['HTTP_HOST'].to_s, path: clean_uuids(env['PATH_INFO'])}
    result= Metrics.counter(name: 'api_http_requests', docstring: 'Counter of HTTP requests done', base_labels: labels)
    LOGGER.debug(component:LOGGED_COMPONENT, operation:msg, message:"Counter KPI: result=#{result}")
    result=Metrics.gauge(name: 'api_http_request_duration_seconds', value: headers['X-Timing'], docstring: 'Time taken by each HTTP request', base_labels: labels)
    LOGGER.debug(component:LOGGED_COMPONENT, operation:msg, message:"Gauge KPI: result=#{result}")
    [status, headers, body]
  end
  
  private
  def clean_uuids(string_with_uuid)
    return '' unless string_with_uuid
    string_with_uuid.gsub(/[a-f0-9]{8}-[a-f0-9]{4}-4[a-f0-9]{3}-[89aAbB][a-f0-9]{3}-[a-f0-9]{12}/, ':uuid\\1') #'/api/v3/requests/76acf635-b982-4a05-805b-3433976e6aa9/another'.to_s.gsub(/[a-f0-9]{8}-[a-f0-9]{4}-4[a-f0-9]{3}-[89aAbB][a-f0-9]{3}-[a-f0-9]{12}/, ':uuid\\1')
  end
end


