# Author: Rodolfo Carvalho <rodolfo@nybusinesslink.com>
AR_PRESENT = defined?(ActiveSupport::JSON) and ActiveSupport::JSON.respond_to?(:decode)

require 'contacts'

require 'rubygems'
require 'hpricot'
require 'cgi'
require 'time'
require 'zlib'
require 'stringio'
require 'net/http'
require 'net/https'
require 'uri'
require json unless AR_PRESENT

module Contacts
  class AOL
    CONFIG_FILE = File.dirname(__FILE__) + '/../config/contacts.yml'
    LOGIN_URL = "http://api.screenname.aol.com/auth/login?f=qs&devId=#id&succUrl=#url&supportedIdType=#sid"
    PRESENCE_URL = "http://api.oscar.aol.com/presence/get?f=json&bl=1&k=#id&a=#token"

    def initialize(config=CONFIG_FILE)
      confs = YAML::load_file(config)['aol']
      @dev_id = confs['dev_id']
      @return_url = confs['return_url']
      @supported_types = confs['supported_ids'] || ["SN"]
    end

    def authentication_url
      url = LOGIN_URL.dup
      url.gsub!(/#id/, @dev_id)
      url.gsub!(/#url/, CGI.escape(@return_url))
      url.gsub!(/#sid/, @supported_types.join(","))
      url
    end
    
    def contacts(token)
      url = PRESENCE_URL.dup
      url.gsub!(/#id/, @dev_id)
      url.gsub!(/#token/, token)
      uri = URI.parse(url)
      response = Net::HTTP::Request.start(uri.host, uri.port) do |http|
        http.get("#{uri.path}?#{uri.query}")
      end
      
      if response.kind_of?(Net::HTTPSuccess)
        body = if AR_PRESENT
          ActiveSupport::JSON.decode(response.body)
        else
          JSON.loads(response.body)
        end
        return body
      else
        return "An Error has occurrend: #{response.class}"
      end
    end
  end
end
