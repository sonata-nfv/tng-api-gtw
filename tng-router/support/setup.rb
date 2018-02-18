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
require 'yaml'
require 'active_support'

class Setup
  
  def self.configure
    middlewares = symbolize YAML::load_file(File.join(__dir__, '..', 'config', 'middlewares.yml'))
    configuration = symbolize YAML::load_file(File.join(__dir__, '..', 'config', 'sp_routes.yml'))
        
    @@basic_path = configuration[:basic_path]
    @@paths = configuration[:paths]
    @@loading_paths = middlewares[:loading_paths]
    @@middlewares = middlewares
  end
  
  def self.basic_path() @@basic_path end
  def self.paths() @@paths end
  def self.loading_paths() @@loading_paths end
  def self.middlewares() @@middlewares end
  
  private
  # from https://gist.github.com/Integralist/9503099
  def self.symbolize(obj)
    return obj.reduce({}) do |memo, (k, v)|
      memo.tap { |m| m[k.to_sym] = symbolize(v) }
    end if obj.is_a? Hash
    
    return obj.reduce([]) do |memo, v| 
      memo << symbolize(v); memo
    end if obj.is_a? Array
    obj
  end
end
=begin
def create_rate_limits()
  log_message = 'GtkApi.'+__method__.to_s
  settings.logger.debug(log_message) {'entered'}
  limits = settings.services['rate_limiter']['limits']
  settings.logger.debug(log_message) {"limits are #{limits}"}
  limits.each do |name, values|
    settings.logger.debug(log_message) {"limit is #{name}"}
    settings.logger.debug(log_message) {"values are #{values}"}
    params = {limit: values['limit'], period: values['period'], description: values['description']}
    begin
      resp = Object.const_get(settings.services['rate_limiter']['model']).create(name: name, params: params)
      settings.logger.debug(log_message) {"resp = #{resp}"}
      settings.logger.error(log_message) {'Rate limiter is in place, but could not create a limit'} unless (resp || resp[:status] == 201)
    rescue RateLimitNotCreatedError => e
      settings.logger.error(log_message) {'Failled to create rate limit'}
      json_error 500, {error: { code: 500, message:'There seems to have been a problem with rate limit creation'}}.to_json
    end
  end
  settings.logger.debug(log_message) {'Setting rate_limits_created to true...'} 
  settings.rate_limits_created=true
  settings.logger.debug(log_message) {"...set (#{settings.rate_limits_created})!"} 
end

def check_rate_limit(limit: , client:)
  log_message = 'GtkApi.'+__method__.to_s
  settings.logger.debug(log_message) {'entered'}
  if settings.services['rate_limiter']
    settings.logger.debug(log_message) {"settings.services['rate_limiter']=#{settings.services['rate_limiter']}"}
    create_rate_limits() unless settings.rate_limits_created

    begin
      resp = Object.const_get(settings.services['rate_limiter']['model']).check(params: {limit_id: limit, client_id: client})
      settings.logger.debug(log_message) {"resp is #{resp}"}
      halt 429, {error: { code: 429, message:'GtkApi: Too many user creation requests were made'}}.to_json unless resp[:allowed]
      resp[:remaining]
    rescue RateLimitNotCheckedError => e
      halt 400, {error: { code: 400, message:'There seems to have been a problem with user creation rate limit validation'}}.to_json
      '0' # Allows this request to proceed
    end
  end
end

def check_rate_limit_usage()
  settings.use_rate_limit && !(settings.services['rate_limiter'].to_s.empty?)
end
=end
