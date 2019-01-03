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
require 'json'

module Utils
  SYMBOL_TO_STATUS_CODE = Rack::Utils::SYMBOL_TO_STATUS_CODE
  HTTP_STATUS_CODES = Rack::Utils::HTTP_STATUS_CODES
  
#  def method_missing(method_name, *args, &block) #:nodoc:
#    @tempfile.__send__(method_name, *args, &block)
#  end

  CONTENT_TYPE={'content-type'=>'application/json'}

  def bad_request(msg=nil) [400, CONTENT_TYPE, [{error:{code:400, message:"#{msg || 'Invalid Request'}"}}.to_json]] end
  def unauthorized(msg=nil) [401, CONTENT_TYPE, [{error:{code:401, message:"#{msg || 'Unauthorized'}"}}.to_json]] end  
  def forbidden(msg=nil) [403, CONTENT_TYPE, [{error:{code:403, message:"#{msg || 'Forbidden'}"}}.to_json]] end
  def not_found(msg=nil) [404, CONTENT_TYPE, [{error:{code:404, message:"#{msg || 'Not Found'}"}}.to_json]] end
  def method_not_allowed(msg=nil) [405, CONTENT_TYPE, [{error:{code:405, message:"#{msg || 'Method Not Allowed'}"}}.to_json]] end
  def internal_server_error(msg=nil) [500, CONTENT_TYPE, [{error:{code:500, message:"#{msg || 'Internal Server Error'}"}}.to_json]] end
  def not_implemented(msg=nil) [501, CONTENT_TYPE, [{error:{code:501, message:"#{msg || 'Not Implemented'}"}}.to_json]] end
  def respond(status, headers, body) [status, headers, body.is_a?(Array) ? body : [body]] end 
  def choose_logger(env)
    (env['rack.logger'.freeze]) ? env['rack.logger'.freeze] : Rack::NullLogger
  end
end