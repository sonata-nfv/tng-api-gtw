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
require 'net/http'
require 'uri'
require_relative '../../utils'

class OtherMethods
  attr_accessor :app
  
  include Utils
  
  def initialize(app, options= {})
    @app = app
    STDERR.puts "Initialized #{self.class.name}"
  end

  def call(env)
    msg = self.class.name+'#'+__method__.to_s
    env['5gtango.logger'].info(msg) {"Called"}
    #url = env['5gtango.sink_path'.freeze]
    request = Rack::Request.new(env)  
    
    # Pass non-HEAD, DELETE or OPTIONS requests
    return @app.call(env) unless (request.head? || request.options? || request.delete?)
    
    #connection = Faraday.new(url) { |conn| conn.adapter :net_http }
    # from https://augustl.com/blog/2010/ruby_net_http_cheat_sheet/
    uri = URI.parse(env['5gtango.sink_path'.freeze])
    http = Net::HTTP.new(uri.host, uri.port)
    
    method_name = request.request_method.downcase.to_sym
    # from https://stackoverflow.com/questions/35667746/preflight-options-request-with-faraday-gem
    case method_name
    when :options
      #resp = connection.run_request(:options, nil, nil, nil) do |req|
      #  req.url url
      #  req.headers['Content-Type'] = request.content_type
      #end
      http_request = Net::HTTP::Options.new(uri.request_uri)
      http_request["Content-Type"] = request.content_type
      response = http.request(http_request)
      response.header['Access-Control-Allow-Origin'] = '*'
      response.header['Access-Control-Allow-Methods'] = 'POST,GET,DELETE'      
      response.header['Access-Control-Allow-Headers'] = 'Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With'
    when :head
      http_request = Net::HTTP::Head.new(uri.request_uri)
      response = http.request(http_request)
    when :delete
      http_request = Net::HTTP::Delete.new(uri.request_uri)
      response = http.request(http_request)
      #elsif connection.respond_to?(method_name) && [:delete, :head].include?(method_name)
      #resp = connection.public_send(method_name) do |req|
      #  req.url url
      #  req.headers['Content-Type'] = request.content_type
      #end
    else
      return bad_request("HTTP method (#{request.request_method} not supported")
    end
    env['5gtango.logger'].debug(msg) {"Response was #{response}"}
    respond(response.status, response.headers, response.body)
  end    
  
  private
  
  def allowed_content_type(content_type)
    (content_type =~ /application\/json/) || (content_type =~ /application\/yaml/) || (content_type =~ /application\/xml/)
  end
end

=begin
http = Net::HTTP.new(uri.host, uri.port)
http.open_timeout = 3 # in seconds
http.read_timeout = 3 # in seconds

# The request.
request = Net::HTTP::Get.new(uri.request_uri)

# All the HTTP 1.1 methods are available.
Net::HTTP::Get
Net::HTTP::Post
Net::HTTP::Put
Net::HTTP::Delete
Net::HTTP::Head
Net::HTTP::Options

request.body = "Request body here."
request.initialize_http_header({"Accept" => "*/*"})
request.basic_auth("username", "password")

response = http.request(request)
response.body
response.status
response["header-here"] # All headers are lowercase
=end
