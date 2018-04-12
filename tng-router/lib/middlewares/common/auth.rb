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
require 'curb'
require_relative '../../utils'

class Auth
  include Utils
  attr_accessor :app, :auth_uri
  
  class UserTokenNotActiveError < StandardError; end
  class UserNotFoundError < StandardError; end
  
  def initialize(app, options= {})
    @app, @auth_uri = app, options[:auth_uri]
  end

  def call(env)
    msg = self.class.name+'#'+__method__.to_s
    env['5gtango.logger'].info(msg) {"Called"}
    
    # Just forward request if no authorization token is provided
    return @app.call(env) if (env['HTTP_AUTHORIZATION'].to_s.empty?)
      
    # Authorization token is provided, it has to be in the form of 'bearer: <token>'
    token = env['HTTP_AUTHORIZATION'].split(' ')
    return bad_request('Unauthorized: missing authorization (bearer) header') unless bearer_token?(token:token)
    begin
      user = find_user_by_token(token: token[1])
      env['5gtango.user.name'] = user[:preferred_username]
      status, headers, body = @app.call(env)
      env['5gtango.logger'].info(msg) {'Finishing with status = '+status.to_s}
      return [status, headers, body]
    rescue UserTokenNotActiveError
      env['5gtango.logger'].error(msg) {'Finishing with Unauthorized:'}
      return unauthorized('Unauthorized: token  not active')
    rescue UserNotFoundError
      env['5gtango.logger'].error(msg) {'Finishing with not found'}
      return not_found('Not found: user not found')
    else
      env['5gtango.logger'].error(msg) {'Finishing with internal server error'}
      return internal_server_error('Internal error in '+self.class.name)
    end
  end
  
  private
  def bearer_token?(token:)
    token.size == 2 && token[0].downcase == 'bearer'
  end
  
  def find_user_by_token(token:)
    
    resp = Curl.post( @auth_uri, '') do |req|
      req.headers['Content-type'] = req.headers['Accept'] = 'application/json'
      req.headers['Authorization'] = 'Bearer '+token
    end
    
    # {:sub=>"fe53ac4f-052a-4a41-b7cd-914d4c64c2f8", :name=>"", :preferred_username=>"jbonnet", :email=>"jbonnet@alticelabs.com"}
    case resp.response_code
    when 201
      begin
        JSON.parse(resp.body, symbolize_names: true)
      rescue => e
        puts "#{self.class.name}: Error processing #{$!}: \n\t#{e.backtrace.join('\n\t')}"
        nil
      end
    when 401
      raise UserTokenNotActiveError.new "User token was not active"
    else
      raise UserNotFoundError.new "User not found with the given token"
    end  
  end
end
