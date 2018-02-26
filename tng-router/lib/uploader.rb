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
require 'faraday'
require 'tempfile'
require 'fileutils'
require 'net/http/post/multipart'

class Uploader
  attr_accessor :app
  
  include Utils
  def call(env)
    @logger = choose_logger(env)
    msg = self.class.name+'#'+__method__.to_s
    @logger.info(msg) {"Called"}
    url = URI.parse( env['5gtango.sink_path'.freeze] )
    
    req = Rack::Request.new(env)
        
    bad_request('No files to upload') unless req.form_data?
    name=random_string
    tempfile = Tempfile.new(name, '/tmp')#, dirname)
    env['rack.input'].rewind
    tempfile.write env['rack.input'].read
    env['rack.input'].rewind
    @logger.debug(msg) {"#{name} will contain #{env['rack.input'].read}"}
    post_req = Net::HTTP::Post.new(url)
    post_stream = File.open(tempfile, 'rb') #env['rack.input'].read
    post_req.content_length = post_stream.size
    post_req.content_type = env['CONTENT_TYPE'] #'multipart/form-data; boundary=' + boundary
    post_req.body_stream = post_stream
    resp = Net::HTTP.new(url.host, url.port).start {|http| http.request(post_req) }
    respond(resp.code, {'Content-Type'=>'application/json'}, resp.body)
  end
  
  private
  def random_string
    (0...8).map { (65 + rand(26)).chr }.join
  end
end
=begin
require 'net/http/post/multipart'

url = URI.parse('http://www.example.com/upload')
File.open("./image.jpg") do |jpg|
  req = Net::HTTP::Post::Multipart.new url.path,
    "file" => UploadIO.new(jpg, "image/jpeg", "image.jpg")
  res = Net::HTTP.start(url.host, url.port) do |http|
    http.request(req)
  end
end

To post multiple files or attachments, simply include multiple parameters with UploadIO values:

require 'net/http/post/multipart'

url = URI.parse('http://www.example.com/upload')
req = Net::HTTP::Post::Multipart.new url.path,
  "file1" => UploadIO.new(File.new("./image.jpg"), "image/jpeg", "image.jpg"),
  "file2" => UploadIO.new(File.new("./image2.jpg"), "image/jpeg", "image2.jpg")
res = Net::HTTP.start(url.host, url.port) do |http|
  http.request(req)
end

    #if request.content_type =~ /multipart\/form-data/
      #multipart = Rack::Multipart.parse_multipart env
      #@logger.debug(msg) {"Multipart: #{multipart}"}
      #file_info = multipart.values.find {|f| f.is_a? Hash and f.key? :tempfile }
      #body = file_info[:tempfile].read
      #connection = Faraday.new(url) do |conn|
      #  conn.request :multipart
      #  conn.adapter :net_http
      #end
      #begin
      #  response = connection.post do |req|
      #    req.headers['Content-Type'] = request.content_type
      #    req.body = Faraday::UploadIO.new(body, request.content_type)
      #  end
      #rescue Faraday::Error::ConnectionFailed => e
      #  $stderr.puts "The server at #{url} is either unavailable or is not currently accepting requests. Please try again in a few minutes."
      #  return [500, env, ["No response by GETing #{url}"+ params == {} ? "" : " with params #{params}"]]
      #curl = Curl::Easy.new(url)
      #curl.multipart_form_post = true
      #curl.http_post( Curl::PostField.file('package', file_path)) #Curl::PostField.content('source', 'embedded'), 
      #@logger.debug(msg) {"curl.body_str=#{curl.body_str}"}
      #response = {status: curl.response_code, headers: curl.headers, body: JSON.parse(curl.body_str)}
      #file_info[:tempfile].close
      #file_info[:tempfile].unlink

=end