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
require 'rack/show_exceptions'
require 'sinatra/base'
require 'yaml'
require 'net/http'
require "uri"
require_relative '../../dispatcher'
require_relative '../utils'
require 'tng/gtk/utils/logger'

class ConfigFinder
  LOGGER=Tng::Gtk::Utils::Logger
  LOGGED_COMPONENT=self.name
  include Utils

  class MethodNotAllowedError < StandardError; end
  class MethodNeedsAuthenticationError < StandardError; end
  
  def initialize(app, options={})
    @app, @paths = app, options[:paths]
    @base_path = options[:base_path] || ''
    LOGGER.debug(component:LOGGED_COMPONENT, operation:'initialize', message:"Initialized #{self.class.name} with base_path=#{@base_path} and paths=#{@paths}")
  end

  def call(env)
    msg = '#call'
    LOGGER.debug(component:LOGGED_COMPONENT, operation:msg, message:"Env=#{env}")
    begin
      request=Rack::Request.new(env)
      config_key = get_config_key(request.path)
      LOGGER.debug(component:LOGGED_COMPONENT, operation:msg, message:"config_key: #{config_key}")
      return bad_request("Error finding #{request.request_method} for #{request.path}") if config_key.nil?
      env['5gtango.verbs'] = get_permited_verbs(env, @paths[config_key.to_sym][:permissions])
      env['5gtango.sink_path'] = build_path(request, config_key.to_sym)
    rescue MethodNotAllowedError => e
      LOGGER.error(component:LOGGED_COMPONENT, operation:msg, message:e.message)
      return not_found e.message
    rescue MethodNeedsAuthenticationError => e
      LOGGER.error(component:LOGGED_COMPONENT, operation:msg, message:e.message)
      return forbidden e.message
    rescue Exception => e
      LOGGER.error(component:LOGGED_COMPONENT, operation:msg, message:e.message)
      return bad_request e.message
    end
    LOGGER.debug(component:LOGGED_COMPONENT, operation:msg, message:"path built: #{env['5gtango.sink_path']}")
    status, headers, body = @app.call(env)
    LOGGER.debug(component:LOGGED_COMPONENT, operation:msg, message:"Finishing with status #{status}")
    respond(status, headers, body)
  end
  
  def build_path(request, router_path)
    msg = '#'+__method__.to_s    
    simple_path = request.path
    simple_path.slice!(@base_path) unless @base_path == ''
    path_templates=Mustermann.new(router_path.to_s).to_templates
    LOGGER.debug(component:LOGGED_COMPONENT, operation:msg, message:"path_templates: #{path_templates}")
    final_path = ''
    path_templates.each do |template|
      LOGGER.debug(component:LOGGED_COMPONENT, operation:msg, message:"template: #{template.inspect}")
      full_match, *match = *Mustermann.new(template).match(simple_path)
      LOGGER.debug(component:LOGGED_COMPONENT, operation:msg, message:"full_match: #{full_match.inspect}\nmatch: #{match.inspect}")
      if full_match
        final_path = match.first
        LOGGER.debug(component:LOGGED_COMPONENT, operation:msg, message:"final_path: #{final_path}")
        break
      end
    end
    # WRONG! We need the rest of the string
    # .../api/v3/packages/status/1234... is not being correctely translated into .../packages/status/1234...
    "#{@paths[router_path][:site]}#{final_path?(final_path)}#{query_string?(request.query_string)}"
  end
  
  private
  def get_config_key(request_path)
    msg = '#'+__method__.to_s
    chomped_path = request_path
    chomped_path.slice!(@base_path) unless @base_path == ''
    LOGGER.debug(component:LOGGED_COMPONENT, operation:msg, message:"chomped_path: #{chomped_path}")
    
    possible_paths = @paths.keys.select { |path| chomped_path =~ Mustermann.new(path.to_s)}
    LOGGER.debug(component:LOGGED_COMPONENT, operation:msg, message:"possible_paths: #{possible_paths}")
    #longest_path = possible_paths.max_by(&:length)
    #return nil if longest_path.nil?
    #@paths[longest_path.to_sym]
    return nil if possible_paths.empty?
    possible_paths.first
  end
  
  def request_method(env) env['REQUEST_METHOD'.freeze].downcase.to_sym end
  def is_authenticated?(env) env.key?('5gtango.user.name') end
  def get_permited_verbs(env, permissions)
    permissions.each { |permission| return permission[:verbs] if permission[:role] == env['5gtango.user.role']}
    ''
  end
  
  def final_path?(str) str.to_s.empty? ? '' : '/'+str end
  def query_string?(str) str.empty? ? '' : '?'+str end
end