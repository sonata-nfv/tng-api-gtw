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
require 'jwt'
require 'time'
require 'tng/gtk/utils/logger'
require_relative '../utils'

class Authentication
  LOGGER=Tng::Gtk::Utils::Logger
  LOGGED_COMPONENT=self.name
  @@began_at = Time.now.utc
  LOGGER.info(component:LOGGED_COMPONENT, operation:'initializing', start_stop: 'START', message:"Started at #{@@began_at}")
  
  #AUTH_URL = ENV.fetch('AUTH_URL', '')
  include Utils
  attr_accessor :app, :auth_uri
  
  class UserTokenNotActiveError < StandardError; end
  class UserNotFoundError < StandardError; end
  class UserDataNotParseableError < StandardError; end
  
  def initialize(app, options= {})
    @app = app
  end

  def call(env)
    msg = '#'+__method__.to_s
    #auth_url = ENV.fetch('AUTH_URL', '')
    #if auth_url.empty?
    #  LOGGER.error(component:LOGGED_COMPONENT, operation: msg, message:'No AUTH_URL defined', status: '400')
    #  LOGGER.info(component:LOGGED_COMPONENT, operation: msg, start_stop: 'STOP', message:"Ended at #{Time.now.utc}", time_elapsed:"#{Time.now.utc-@@began_at}")
    #  return bad_request('No AUTH_URL ENV variable defined') 
    #end
        
    # Just forward request if no authorization token is provided
    return @app.call(env) if (env['HTTP_AUTHORIZATION'].to_s.empty?)
      
    # Authorization token is provided, it has to be in the form of 'bearer: <token>'
    token = env['HTTP_AUTHORIZATION'].split(' ')
    LOGGER.debug(component:LOGGED_COMPONENT, operation:msg, message:"token=#{token}")
    unless bearer_token?(token:token)
      LOGGER.error(component:LOGGED_COMPONENT, operation:msg, start_stop: 'STOP', message:'Unauthorized: missing authorization (bearer) header', time_elapsed:"#{Time.now.utc-@@began_at}", status: '400')
      return bad_request('Unauthorized: missing authorization (bearer) header') 
    end
    begin
      decoded_token = symbolize JWT.decode(token[1], nil, false).first
      LOGGER.debug(component:LOGGED_COMPONENT, operation:msg, message:"decoded_token=#{decoded_token}")
    rescue JWT::DecodeError => exception
      LOGGER.error(component:LOGGED_COMPONENT, operation:msg, start_stop: 'STOP', message:'Error decoding token '+token[1], time_elapsed:"#{Time.now.utc-@@began_at}", status: '400')
      return bad_request('Bad request: could not decode token')
    end
    # JWT.decode 'eyJhbGciOiJIUzI1NiJ9.eyJ1c2VybmFtZSI6InBhY28iLCJlbWFpbCI6InBhY29AcGFjbyIsImVuZHBvaW50cyI6W3siZW5kcG9pbnQiOiJwYWNrYWdlcyIsInZlcmJzIjoiZ2V0LHBvc3QscHV0In0seyJlbmRwb2ludCI6InNlcnZpY2VzIiwidmVyYnMiOiJnZXQscG9zdCJ9XSwibG9naW5fdGltZSI6IjIwMTgtMTItMDYgMjE6NTA6MzcgKzAxMDAiLCJleHBpcmF0aW9uX3RpbWUiOiIyMDE4LTEyLTA2IDIyOjUwOjM3ICswMTAwIn0.gT7sAZdOvB-61F3VLUQSlvY6Tj87_miXqHkmrlnJaPQ', nil, false
    
    unless token_valid?(token:decoded_token)
      LOGGER.error(component:LOGGED_COMPONENT, operation:msg, start_stop: 'STOP', message:"Unauthorized: token #{decoded_token} is not valid", time_elapsed:"#{Time.now.utc-@@began_at}", status: '401')
      return unauthorized('Anauthorized: token is not valid') 
    end
    #unless endpoint_and_method_authorized?(endpoints:decoded_token[:endpoints], endpoint:env['PATH_INFO'], method: env['REQUEST_METHOD']) 
    #  LOGGER.error(component:LOGGED_COMPONENT, operation:msg, start_stop: 'STOP', message:"Forbidden: method #{env['REQUEST_METHOD']} in path #{env['REQUEST_PATH']}", time_elapsed:"#{Time.now.utc-@@began_at}", status: '403')
    #  return forbidden("Forbidden: method #{env['REQUEST_METHOD']} in path #{env['REQUEST_PATH']}") 
    #end
    env['5gtango.user.name'] = find_user_name_by_token(token: decoded_token)
    env['5gtango.user.email'] = find_user_email_by_token(token: decoded_token)
    #env['5gtango.user.token'] = token[1]
    env['5gtango.user.role'] = decoded_token[:role]
    env['5gtango.user.endpoints'] = decoded_token[:endpoints].to_json
    LOGGER.debug(component:LOGGED_COMPONENT, operation:msg, message:"env=#{env}")
    LOGGER.info(component:LOGGED_COMPONENT, operation:msg, start_stop: 'STOP', message:'Calling app...', time_elapsed:"#{Time.now.utc-@@began_at}", status: '200')
    @app.call(env)
  end
  
  private
  def bearer_token?(token:)
    STDERR.puts "bearer_token? #{token}"
    return false if token.to_s.empty?
    token.size == 2 && token[0].downcase == 'bearer'
  end
  
  def token_valid?(token:)
    STDERR.puts "token_valid? #{token}"
    return false unless token.key?(:expiration_time)
    Time.parse(token[:expiration_time]) > Time.now
  end
    
  def find_user_name_by_token(token:)
    return '' unless token.key?(:username)
    token[:username] 
  end
  def find_user_email_by_token(token:)
    return '' unless token.key?(:email)
    token[:email]
  end
  def endpoints_adapter(endpoints)
    # from [{"endpoint": "/","roles": [],"verb": "get"}, {"endpoint": "/user","roles": ["admin", "developer"],"verb": "post"}]
    # to   {:/=>{:get=>[]}, :"/api/v3/users"=>{:post=>["a", "c", "d"], :get=>["a"]}}
    STDERR.puts "endpoints_adapter: endpoints=#{endpoints}"
    transformed = {}
    endpoints.each do |endpoint|
      
    end
    STDERR.puts "endpoints_adapter: transformed=#{transformed}"
    transformed
  end
  LOGGER.info(component:LOGGED_COMPONENT, operation:'initializing', start_stop: 'STOP', message:"Ended at #{Time.now.utc}", time_elapsed:"#{Time.now.utc-@@began_at}")
end

