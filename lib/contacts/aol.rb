# Author: Rodolfo Carvalho <rodolfo@nybusinesslink.com>

require 'contacts'

require 'rubygems'
require 'hpricot'
require 'cgi'
require 'time'
require 'zlib'
require 'stringio'
require 'net/http'
require 'net/https'

module Contacts
  class AOL
    CONFIG_FILE = File.dirname(__FILE__) + '/../config/contacts.yml'
    LOGIN_URL = "http://api.screenname.aol.com/auth/login?f=qs&r=27&devId=#id&succUrl=#url&supportedIdType=#sid"

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
  end
end
