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
require 'json'
require 'faraday'
require 'tempfile'
require 'fileutils'
require 'net/http/post/multipart'
require_relative './utils'

class Uploader
  attr_accessor :app
  
  include Utils
  def call(env)
    msg = self.class.name+'#'+__method__.to_s
    env['5gtango.logger'].info(msg) {"Called"}

    req = Rack::Request.new(env)
    bad_request('No files to upload') unless req.form_data?

    Tempfile.open do |tempfile|
      tempfile.binmode
      tempfile.write env['rack.input'].read
      tempfile.flush
      env['5gtango.logger'].debug(msg) {"Tempfilename #{tempfile.path} will contain #{tempfile.size} bytes"}
      tempfile.rewind
      begin
        env['5gtango.logger'].debug(msg) {"Calling #{env['5gtango.sink_path']}"}
        conn = Faraday.new(url: env['5gtango.sink_path']) do |faraday|
          faraday.request :multipart
          #faraday.response :logger
          faraday.adapter :net_http
        end
        resp = conn.post do |req|
          req.headers['Content-Type'] = env['CONTENT_TYPE'] 
          req.headers['Content-Length'] = tempfile.size.to_s
          req.body = Faraday::UploadIO.new(tempfile, 'octet/stream')
        end
        return respond(200, {'Content-Type'=>'application/json'}, resp.body)
      rescue => e
        env['5gtango.logger'].debug(msg) {"Exception caught at POSTing body: #{e.message}\n#{e.backtrace.join("\n\t")}"}
        return respond(400, {'Content-Type'=>'application/json'}, {error: "Exception caught at POSTing body: #{e.message}\n#{e.backtrace.join("\n\t")}"})
      end
    end
    env['5gtango.logger'].debug(msg) {"A problem occurred with POSTing the body"}
    respond(400, {'Content-Type'=>'application/json'}, {error: "A problem occurred with POSTing the body"}.to_json)
  end
end