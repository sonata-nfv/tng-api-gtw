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
require_relative '../../../dispatcher'
require_relative '../../utils'

class UpstreamFinder
  include Utils
  def initialize(app, options={})
    @app, @paths = app, options[:paths]
    @base_path = options[:base_path] || ''
    $stdout.puts "Initialized #{self.class.name} with base_path=#{@base_path} and paths=#{@paths}"
  end

  def call(env)
    msg = self.class.name+'#'+__method__.to_s
    env['5gtango.logger'] = Logger.new(STDERR) if env['5gtango.logger'].to_s.empty?
    
    @logger = env['5gtango.logger']
    env['5gtango.logger'].info "Called"
    request = Rack::Request.new(env)
    env['5gtango.logger'].debug(msg) {"Base_path=#{@base_path} and paths=#{@paths}"}
    
    simple_path = env["REQUEST_PATH"]
    simple_path.slice!(@base_path)
    path = find_path(env["REQUEST_PATH"])
    return bad_request("Error finding #{request.request_method}") if path.nil?
    path[:verbs] = [ 'get' ] unless path.key?(:verbs)
    
    not_found("#{request.request_method} is not supported by #{path[:site]}, only #{path[:verbs].join(', ')}") unless method_ok?(path[:verbs], request.request_method)
    #forbidden("#{request.request_method}ing into #{path[:site]} needs authentication") unless authenticated?(path, env)
    env['5gtango.sink_path'] = path[:site]+query_string?(env["QUERY_STRING"])
    env['5gtango.logger'].debug(msg) {"path built: #{env['5gtango.sink_path']}"}
    status, headers, body = @app.call(env)
    env['5gtango.logger'].debug(msg) {"Finishing with status #{status}"}
    respond(status, headers, body)
  end
  
  private
  def find_path(request_path)
    msg = self.class.name+'#'+__method__.to_s
    chomped_path = request_path
    chomped_path.slice!(@base_path)
    @logger.debug(msg) {"chomped_path: #{chomped_path}"}
    
    possible_paths = @paths.keys.select { |path| chomped_path =~ Mustermann.new(path.to_s)}
    @logger.debug(msg) {"possible_paths: #{possible_paths}"}
    longest_path = possible_paths.max_by(&:length)
    return nil if longest_path.nil?
    @paths[longest_path.to_sym]
  end
  
  def method_ok?(allowed_methods, method)
    methods_to_s(allowed_methods).include? method.downcase
  end
  
  def methods_to_s(methods)
    methods_in_string=[]
    methods.each do |m|
      methods_in_string << (m.is_a?(String) ? m : (m.is_a?(Hash) ? m.keys[0].to_s : m.to_s))
    end
    methods_in_string
  end
  
  def authenticated?(path, env)
    needs_authentication?( path, env['REQUEST_METHOD'.freeze].downcase.to_sym) && env.key?('5gtango.user.name')
  end

  def needs_authentication?(path, method)
    return path[:verbs] if path.key?(:auth)
    methods_needing_auth()
    a=[]
    path[:verbs].each do |method|
      a << method if (method.is_a?(Hash) && method.values[0][:auth])
    end
    a.keys
  end
  
  def query_string?(str)
    str.empty? ? '' : '?'+str
  end
end