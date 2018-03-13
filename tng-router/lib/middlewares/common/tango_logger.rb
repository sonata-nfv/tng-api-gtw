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
require 'logger'

class TangoLogger
  include Utils
  attr_accessor :app, :logger, :level
  
  LOGGER_LEVELS = ['debug', 'info', 'warn', 'error', 'fatal', 'unknown'].freeze
  FORMAT = %{%s - %s [%s] "%s %s%s %s" %d %s %0.4f\n}

  class MyLogger
    def initialize(app, options = {})
      @app = app
    end

    def call(env)
      env['rack.logger']=Logger.new($stderr)
      puts "#{msg}: env['rack.error']: #{env['rack.error']}"
      puts "#{msg}: env['rack.logger']: #{env['rack.logger']}"
      @app.call(env)
      puts "#{msg}: env['rack.error']: #{env['rack.error']}"
      puts "#{msg}: env['rack.logger']: #{env['rack.logger']}"
      [200, {}, ['MyLogger called']]
    end

    def debug(str)
      @err_io.puts(str)
    end
  end
  class App
    def call(env)
      msg=self.class.name+__method__.to_s
      puts "#{msg}: env['rack.error']: #{env['rack.error']}"
      env['rack.error'].puts "#{msg}: env['rack.error']: #{env['rack.error']}" if env['rack.error']
      env['rack.logger'].debug "#{msg}: env['rack.logger']: #{env['rack.logger']}" if env['rack.logger']
      puts "#{msg}: env['rack.logger']: #{env['rack.logger']}"
      env['rack.error'].write "Written to env[rack.error]\n"
      [200, {}, ['MyLogger called']]
    end
  end
  
  def initialize(app, options = {})
    @app = app
    @error_io = options[:logger_io]
    @logger = Logger.new(@error_io)
    @error_io.sync = true
    @logger_level = LOGGER_LEVELS.find_index(options[:logger_level].downcase ||= 'debug')
  end

  def call(env)
    msg = self.class.name+'#'+__method__.to_s
    env['rack.error']=@error_io
    env['rack.logger']=@logger
    @logger.info(msg) {"Called"}
    request = Rack::Request.new(env)
=begin
    #[$time_local], $level, $remote_addr '"$request" $status $headers' $message;
    @logger.formatter = proc do |severity, datetime, progname, msg|
      message="[#{datetime}], #{severity}, "
      message << "#{env['HTTP_X_FORWARDED_FOR'] || env['REMOTE_ADDR'] || '-'}"
      message << "#{env['rack.url_scheme']}://#{env['HTTP_HOST']}#{env['REQUEST_PATH']}"
      message << "?#{env['QUERY_STRING']}" if env['QUERY_STRING'].empty?
      message << ", #{status}, #{headers}"
      message << "#{msg}\n"
    end

    env['rack.errors'] = @logger
    status, headers, body = @app.call(env)
    @logger.debug(self.class.name) {"status, headers, body: #{status}, #{headers}, #{body[0]}"}
    [status, headers, body]
=end
    status, headers, body = @app.call(env)
    @logger.info(msg) {"Finishing with status #{status}"}
    [status, headers, body]
  end
end
