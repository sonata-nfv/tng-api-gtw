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
require 'rack/uploads'
require ::File.join(__dir__, 'dispatcher')

# from https://gist.github.com/Integralist/9503099
def symbolize(obj)
  return obj.reduce({}) do |memo, (k, v)|
    memo.tap { |m| m[k.to_sym] = symbolize(v) }
  end if obj.is_a? Hash

  return obj.reduce([]) do |memo, v| 
    memo << symbolize(v); memo
  end if obj.is_a? Array
  obj
end

Dispatcher.configure do |config|
  #app_config = symbolize YAML::load_file(File.join(__dir__, 'config', 'app.yml'))
  routes_file_name = File.join(__dir__, 'config', ENV['ROUTES_FILE'] ||= 'sp_routes.yml')
  routes = symbolize YAML::load_file(routes_file_name)
  
  config.base_path = routes[:base_path]
  config.paths = routes[:paths]
  #config.middlewares = app_config[:middlewares]
  config.root = __dir__
end

Dir.glob(File.join(__dir__, 'lib', '**', '*.rb')).each { |file| require file } if Dir.exist?('lib')

use Instrumentation unless ENV['NO_KPIS']
use Authentication unless ENV['NO_AUTH']
use UpstreamFinder, base_path: Dispatcher.configuration.base_path, paths: Dispatcher.configuration.paths
use Getter
use EmbodiedMethod
use OtherMethods
run Dispatcher.new



