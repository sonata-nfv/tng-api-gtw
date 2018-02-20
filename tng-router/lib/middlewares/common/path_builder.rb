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
require 'rack'
require 'rack/show_exceptions'
require 'sinatra/base'
require 'yaml'
require 'net/http'
require "uri"
require_relative '../../../dispatcher'

class PathBuilder
  def initialize(app, options={})
    @app, @base_path, @paths, @logger = app, options[:base_path], options[:paths], options[:logger]
    puts "Initialized #{self.class.name} with base_path=#{@base_path} and paths=#{@paths}"
  end

  def call(env)
    request = Rack::Request.new(env)
    simple_path = env["REQUEST_PATH"]
    simple_path.slice!(@base_path)
    path = find_path(env["REQUEST_PATH"])
    path[:verbs] = [ 'get' ] unless path.key?(:verbs)
    
    respond(404, {}, "#{request.request_method} is not supported by #{path[:site]}, only #{path[:verbs].join(', ')}") unless path[:verbs].include? request.request_method.downcase
    env['5gtango.full_path'] = path[:site]+@base_path+env["REQUEST_PATH"]
    @logger.debug(self.class.name) {"path built: #{env['5gtango.full_path']}"}
    status, headers, body = @app.call(env)
    @logger.debug(self.class.name) {"status, headers, body#{status}, #{headers}, #{body[0]}"}
    [status, headers, body]
  end
  
  private  
  def respond(status, headers, body)
    [status, headers, [body]]
  end 
  
  def find_path(request_path)
    chomped_path = request_path
    chomped_path.slice!(@base_path)
    @logger.debug(self.class.name+'#'+__method__.to_s) {"chomped_path: #{chomped_path}"}
    
    possible_paths = @paths.keys.select do |path|
      @logger.debug(self.class.name+'#'+__method__.to_s) {"path: #{path}"}
      chomped_path =~ Mustermann.new(path.to_s)
    end
    @logger.debug(self.class.name+'#'+__method__.to_s) { "possible_paths: #{possible_paths}"}
    longest_path = possible_paths.max_by(&:length)
    @paths[longest_path.to_sym]
  end
  
end

  

  
