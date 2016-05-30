require 'base64'

module ActiveRest
  module Authentications
    class Basic < Authentication
      def authenticate! path = nil, params = nil, headers = nil
        connection.connector.headers['Authentication'] = Base64.encode64("#{options[:username]}:#{options[:password]}")
        true
      end
    end
  end
end