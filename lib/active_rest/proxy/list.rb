module ActiveRest
  class Proxy
    module List
      extend ActiveSupport::Concern

      included do
        def list limit = 20, offset = 1, options = {}
          route  = routes[:list]
          response = @model.connection.send( route.method, ProxyHelper.replace_path_attributes(options, route.path), { route.options[:offset] => offset.to_i, route.options[:limit] => limit.to_i } )
          route.valid_response(response)
          response
        end
      end
    end
  end
end