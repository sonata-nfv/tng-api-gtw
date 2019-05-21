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
require 'prometheus/client'
require 'prometheus/client/push'
require 'json'
require 'tng/gtk/utils/logger'

class Metrics
  LOGGER=Tng::Gtk::Utils::Logger
  LOGGED_COMPONENT=self.name
  
  unless (@@pushgateway_url=ENV['PUSHGATEWAY_URL'])
    LOGGER.error(component:LOGGED_COMPONENT, operation:'Setting @@pushgateway_url', message:"PUSHGATEWAY_URL ENV variable is missing")
    # how to exit?
  end
  @@prometheus_job_name=ENV.fetch('PROMETHEUS_JOB_NAME', 'sonata')    
    
  # default registry
  @@registry = Prometheus::Client.registry 

  def self.counter(params)
    msg = '#'+__method__.to_s
    LOGGER.debug(component:LOGGED_COMPONENT, operation:msg, message:"params=#{params}")
    base_labels = params.fetch(:base_labels,{})
    factor = params.fetch(:value,1).to_f

    begin
    # if counter exists, it will be increased
      if @@registry.exist?(params[:name].to_sym)
        counter = @@registry.get(params[:name])
        counter.increment(base_labels, factor)        
        Prometheus::Client::Push.new(@@prometheus_job_name, params[:instance], @@pushgateway_url).replace(@@registry)
      else
        # creates a metric type counter
        counter = Prometheus::Client::Counter.new(params[:name].to_sym, params[:docstring], base_labels)
        counter.increment(base_labels, factor)
        # registers counter
        @@registry.register(counter)
        
        # push the registry to the gateway
        Prometheus::Client::Push.new(@@prometheus_job_name, 'default_instance', @@pushgateway_url).add(@@registry) #params[:instance]
      end
    rescue Exception => e
      LOGGER.error(component:LOGGED_COMPONENT, operation:msg, message:"#{e.message}\n#{e.backtrace.join("\n\t")}")
    end
  end

  def self.gauge(params)
    msg = '#'+__method__.to_s
    LOGGER.debug(component:LOGGED_COMPONENT, operation:msg, message:"params=#{params}")
    base_labels = params.fetch(:base_labels,{})
    factor = params.fetch(:value,1).to_f

    begin
      # if gauge exists, it will be updated
      if @@registry.exist?(params[:name].to_sym)
        gauge = @@registry.get(params[:name])
        value = gauge.get(base_labels)
        
        if value == nil 
          value = factor         
        else
          if params[:operation]=='dec'
            value = value.to_f - factor
          else # default operation: inc
            value = value.to_f + factor          
          end          
        end
        gauge.set(base_labels,value)
        Prometheus::Client::Push.new(@@prometheus_job_name, 'default_instance', @@pushgateway_url).replace(@@registry) #params[:instance]
      else
        # creates a metric type gauge
        gauge = Prometheus::Client::Gauge.new(params[:name].to_sym, params[:docstring], base_labels)
        gauge.set(base_labels, factor)
        # registers gauge
        @@registry.register(gauge)
        
        # push the registry to the gateway
        Prometheus::Client::Push.new(params[:job], params[:instance], @@pushgateway_url).add(@@registry) 
      end
    rescue Exception => e
      LOGGER.error(component:LOGGED_COMPONENT, operation:msg, message:"#{e.message}\n#{e.backtrace.join("\n\t")}")
    end
  end
  
=begin
  get '/kpis/?' do
    pushgateway_query = 'http://'+settings.pushgateway_host+':'+settings.pushgateway_port.to_s    
    begin
      if params.empty?
        cmd = 'prom2json '+pushgateway_query+'/metrics | jq -c .'
        res = %x( #{cmd} )

        halt 200, res
        logger.info 'GtkKpi: sonata metrics list retrieved'
      else

        if params[:base_labels] == nil        
          logger.info "GtkKpi: entered GET /kpis with params=#{params}"        
          pushgateway_query = pushgateway_query + '/metrics | jq -c \'.[]|select(.name=="'+params[:name]+'")\''

          cmd = 'prom2json '+pushgateway_query
          res = %x( #{cmd} )
        else
          # jq -c '.[]|select(.name=="counter1")|.metrics|.[]|select(.labels=={"instance":"gtkkpi","job":"sonata","label1":"value1","label2":"value2","label3":"value3"})|.value'          
          base_labels = params['base_labels']
          metric_name = params['name']
          params.delete('base_labels')
          params.delete('name')
          labels = "{"+params.to_s[1..-2]+', '+base_labels.to_s[1..-2]+"}"          
          labels = labels.gsub('=>',':')
          labels = labels.gsub(' ','')
          pushgateway_query = pushgateway_query + '/metrics | jq -c \'.[]|select(.name=="'+metric_name+'")|.metrics|.[]|select(.labels=='+labels+')\''
          logger.debug "prom2json query: "+pushgateway_query

          cmd = 'prom2json '+pushgateway_query
          res = %x( #{cmd} )

          res = JSON.parse(eval(res).to_json)
          res["name"] = metric_name
          res = res.to_s
          res = res.gsub('=>',':')          
        end

        logger.info 'GtkKpi: '+metric_name.to_s+' retrieved: '+res
        halt 200, res
      end
    rescue Exception => e
      logger.debug(e.message)
      logger.debug(e.backtrace.inspect)
      halt 400
    end
  end
=end
end
