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
require 'yaml'
require 'net/http'
require "uri"
require 'logger'
require ::File.join(__dir__, 'dispatcher')

class Dispatcher
  
  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  class Configuration
    attr_accessor :base_path, :paths, :middlewares, :logger
    def initialize
    end
  end
  
  def call(env)
    request = Rack::Request.new(env)  
    
    Dispatcher.configuration.logger.debug(self.class.name+'#'+__method__.to_s) {"verb, full_path, params: #{request.request_method.downcase}, #{env['5gtango.full_path']}, #{request.params}"}
    status, headers, body = process( request.request_method.downcase, env['5gtango.full_path'], request.params)
    Dispatcher.configuration.logger.debug(self.class.name+'#'+__method__.to_s) {"status, headers, body: #{status}, #{headers}, #{body[0]}"}
    [status, headers, body]
  end
  
  private
  def process(verb, full_url, params)
    uri = URI.parse(full_url)
    http = Net::HTTP.new(uri.host, uri.port)
    Dispatcher.configuration.logger.debug(self.class.name) { "http: #{http.inspect}"}
    attribute_url = '?'+URI.encode_www_form(params) if params
    Dispatcher.configuration.logger.debug(self.class.name) {"attribute_url: #{attribute_url}"}
    begin
      case verb
      when 'get'
        response = http.request(Net::HTTP::Get.new(uri.request_uri+attribute_url))
      when 'post'
        request = Net::HTTP::Post.new(uri.request_uri)
        request.set_form_data(params) if params
        request = Net::HTTP::Post.new(uri.request_uri+attribute_url)            
        response = http.request(request)
      when 'put'
        request = Net::HTTP::Put.new(uri.request_uri+attribute_url)
        response = http.request(request)
      when 'patch'
        request = Net::HTTP::Patch.new(uri.request_uri+attribute_url)
        response = http.request(request)
      when 'delete'
        request = Net::HTTP::Delete.new(uri.request_uri+attribute_url)
        response = http.request(request)
      when 'head'
        response = http.request(Net::HTTP::Head.new(uri.request_uri+attribute_url))
      when 'options'
        response = http.request(Net::HTTP::Options.new(uri.request_uri+attribute_url))
      else 
        respond(400, {}, 'Bad request')
      end
    rescue StandardError => e
      respond(500, {}, "Exception #{e.message} #{verb}ing #{full_url} with params #{params}: #{e.backtrace.inspect}")
    end
    return respond(500, {}, "No response by #{verb}ing #{full_url} with params #{params}") if response.nil?
    Dispatcher.configuration.logger.debug(self.class.name) {"response: #{response.inspect}"}
    respond(response.code, response.header, response.body)
    #io.rewind
  end
  
  def respond(status, headers, body)
    [status, headers, [body]]
  end 
  
end