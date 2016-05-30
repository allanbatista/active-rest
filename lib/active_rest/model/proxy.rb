module ActiveRest
  module Model
    module Proxy
      extend ActiveSupport::Concern

      included do
        def self.proxy
          @proxy ||= ActiveRest::Proxy.new(self)
        end

        def self.route type, path, params = {}
          self.proxy.routes[type] = Route.new( path, params[:method], params[:success], params[:headers], params[:options] )
        end

        ##
        # https://www.w3.org/Protocols/rfc2616/rfc2616-sec9.html
        # https://en.wikipedia.org/wiki/List_of_HTTP_status_codes#2xx_Success
        def self.resources base_path, options = {  }
          route :list   , base_path         , options.merge({ method: 'get'   , success: 200 })
          route :find   , "#{base_path}/:id", options.merge({ method: 'get'   , success: [200, 404] })
          route :create , "#{base_path}/"   , options.merge({ method: 'post'  , success: 201 })
          route :update , "#{base_path}/:id", options.merge({ method: 'patch' , success: 204 })
          route :destroy, "#{base_path}/:id", options.merge({ method: 'delete', success: 204 })
        end
      end
    end
  end
end