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
require_relative './support/setup'
require_relative './support/path_processor'

class Dispatcher
  def initialize
    Setup.configure
  
    Setup.loading_paths.each do |folder|
      Dir.glob(File.join(__dir__, folder, '**', '*.rb')).each { |file| require file } if Dir.exist?(folder)
    end
    @basic_path, @paths = Setup.basic_path, Setup.paths

    @app = Rack::Builder.new do
      #use RateLimiter
      use Rack::CommonLogger

      kpis_uri = Setup.middlewares[:middlewares][:kpis][:site]
      use Instrumentation, kpis_uri: kpis_uri unless ENV['NO_KPIS']
      
      auth_uri = Setup.middlewares[:middlewares][:user_management][:site]+Setup.middlewares[:middlewares][:user_management][:path]
      use Auth, auth_uri: auth_uri unless ENV['NO_AUTH']
      
      #use AuthZ
    end
  end

  def call(env)
    request = Rack::Request.new(env)
    simple_path = env["REQUEST_PATH"]
    simple_path.slice!(Setup.basic_path)
    path = Setup.paths[PathProcessor.new(env["REQUEST_PATH"]).call().to_sym]
    path[:verbs] = [ 'get' ] unless path.key?(:verbs)
    
    if path[:verbs].include? request.request_method.downcase
      full_path = path[:site]+Setup.basic_path+env["REQUEST_PATH"]
      process( request.request_method.downcase, full_path, request.params)
    else
      respond(404, {}, "#{request.request_method} is not supported by #{path[:site]}, only #{path[:verbs].join(', ')}")
    end
    #@app.call(env)
  end
  
  private
  def verb(env)
    env["REQUEST_METHOD"].downcase.to_sym
  end
  
  def process(verb, full_url, params)
    puts verb, full_url, params
    uri = URI.parse(full_url)
    http = Net::HTTP.new(uri.host, uri.port)
    puts "http: #{http.inspect}"
    attribute_url = '?'+URI.encode_www_form(params) if params
    puts attribute_url
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
    puts response.inspect
    respond(response.code, response.header, response.body)
    #io.rewind
  end
  
  private
  def respond(status, headers, body)
    [status, headers, [body]]
  end 
#  def bad_request?
#    'What bad request?!?'
#  end
end

  

  
