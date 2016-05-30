require 'faraday'

module ActiveRest
  module Connection
    def enable_stubs!
      @use_stubs = true
    end

    def stubs
      @stubs ||= Faraday::Adapter::Test::Stubs.new
    end
    
    def port port = nil
      @port = port unless port.nil?
      @port ||= 80
    end

    def host host = nil
      @host = host unless host.nil?
      @host
    end

    def protocol protocol = nil
      @protocol = protocol unless protocol.nil?
      @protocol ||= 'http'
    end

    def headers headers = nil
      @headers = headers unless headers.nil?
      @headers ||= {}
    end

    def connector
      @connector ||= Faraday.new(:url => "#{protocol}://#{host}:#{port}") do |builder|
        builder.adapter :test, stubs if @use_stubs
      end
      @connector.headers = headers.merge(@connector.headers)
      @connector
    end

    def authentication authentication_class = nil, options = {}
      @authentication = authentication_class.new(self, options) unless authentication_class.nil?
      @authentication
    end

    def get path, params = {}, headers = {}, auth = authenticate?
      return false if !(!auth || auth && @authentication.authenticate!(path, params, headers))
      
      connector.get do |request|
        request.url path, params
        request.headers = headers.merge( request.headers )
      end
    end

    def delete path, params = {}, headers = {}, auth = authenticate?
      return false if !(!auth || auth && @authentication.authenticate!(path, params, headers))

      connector.delete do |request|
        request.url path, params
        request.headers = headers.merge( request.headers )
      end
    end

    def post path, body = {}, headers = {}, auth = authenticate?
      return false if !(!auth || auth && @authentication.authenticate!(path, body, headers))

      connector.post do |request|
        request.url path
        request.headers = headers.merge( request.headers )
        request.body = body
      end
    end

    def patch path, body = '', headers = {}, auth = authenticate?
      return false if !(!auth || auth && @authentication.authenticate!(path, body, headers))

      connector.patch do |request|
        request.url path
        request.headers = headers.merge( request.headers )
        request.body = body
      end
    end

    def put path, body = '', headers = {}, auth = authenticate?
      return false if !(!auth || auth && @authentication.authenticate!(path, body, headers))

      connector.put do |request|
        request.url path
        request.headers = headers.merge( request.headers )
        request.body = body
      end
    end

    private
      def authenticate?
        !authentication.nil?
      end
  end
end