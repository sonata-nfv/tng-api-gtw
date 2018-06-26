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
    url = URI.parse( env['5gtango.sink_path'] )
    post_req = Net::HTTP::Post.new(url)
    post_req.content_type = env['CONTENT_TYPE'] #'multipart/form-data; boundary=' + boundary
    
    req = Rack::Request.new(env)
    bad_request('No files to upload') unless req.form_data?
        
    env['rack.input'].rewind
    post_req.body_stream=env['rack.input'].read
    env['rack.input'].rewind
      #post_stream = File.open(tempfile, 'rb')
    post_req.content_length = post_req.body_stream.size #tempfile.size #post_stream.size
    env['5gtango.logger'].debug(msg) {"Body will contain #{post_req.body_stream.size} bytes"} # #{tempfile.path} #{env['rack.input'].read} (size
      #post_req.body_stream = body # env['rack.input'].read #post_stream
    resp = Net::HTTP.new(url.host, url.port).start {|http| http.request(post_req) }
    respond(resp.code, {'Content-Type'=>'application/json'}, resp.body)
      #end
  end
  
#  private
#  def random_string
#    (0...8).map { (65 + rand(26)).chr }.join
#  end
end
