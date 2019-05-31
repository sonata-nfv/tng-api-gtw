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
require 'rack/utils'
require 'rack/uploads'
require 'curb'
require 'faraday'
require 'tempfile'
require_relative '../utils'
require 'tng/gtk/utils/logger'

class EmbodiedMethod
  LOGGER=Tng::Gtk::Utils::Logger
  LOGGED_COMPONENT=self.name
  attr_accessor :app
  
  include Utils
  
  def initialize(app, options= {})
    @app = app
  end

  def call(env)
    msg = '#'+__method__.to_s
    LOGGER.debug(component:LOGGED_COMPONENT, operation:msg, message:"Called")
    url = env['5gtango.sink_path']
    request = Rack::Request.new(env)  
    body = request.body.read
    request.body.rewind
    
    # Pass non-POST, PUT or PATCH requests
    return @app.call(env) unless (request.post? || request.put? || request.patch?)
    
    # Pass file uploads
    LOGGER.debug(component:LOGGED_COMPONENT, operation:msg, message:"Content-type: #{request.content_type}")

    if request.content_type =~ /multipart\/form-data/
      #old_params = env['rack.request.form_hash']
      #user_params = {'user_name'=>env.fetch('5gtango.user.name', ''), 'user_email'=>env.fetch('5gtango.user.email', '')}
      #env['rack.request.form_hash'] = user_params.merge old_params
      return Uploader.new.call(env) 
    end
    
    LOGGER.debug(component:LOGGED_COMPONENT, operation:msg, message:"Params: #{request.params}\nBody: #{body}")
    bad_request("Content-type (#{request.content_type} not supported in #{request.request_method} requests") unless allowed_content_type(request.content_type)
    connection = Faraday.new(url) { |conn| conn.adapter :net_http }
    # conn.authorization :Bearer, 'mF_9.B5f-4.1JqM'
    method_name = request.request_method.downcase.to_sym
    if connection.respond_to?(method_name) && [:post, :put, :patch].include?(method_name)
      resp = connection.public_send(method_name) do |req|
        req.url url
        req.headers['Content-Type'] = request.content_type
        req.headers['Authorization'] = 'Bearer '+env['5gtango.user.token'] if env.key?('5gtango.user.token')
        req.headers['X-User-Name'] = env.fetch('5gtango.user.name', '')
        req.headers['X-User-Email'] = env.fetch('5gtango.user.email', '')
        req.body = body
        LOGGER.debug(component:LOGGED_COMPONENT, operation:msg, message:"Params: #{request.params}\nBody: #{body}\nHeaders: #{req.headers}")
      end
    end
    LOGGER.debug(component:LOGGED_COMPONENT, operation:msg, message:"Response was #{resp.inspect}")
    respond(resp.status, resp.headers, resp.body)
  end    
  
  private  
  def allowed_content_type(content_type)
    (content_type =~ /application\/json/) || (content_type =~ /application\/yaml/) || (content_type =~ /application\/xml/)
  end
end
