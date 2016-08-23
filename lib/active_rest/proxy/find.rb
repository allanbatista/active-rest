module ActiveRest
  class Proxy
    module Find
      extend ActiveSupport::Concern

      included do
        def find options = {}
          route  = routes[:find]
          response = @model.connection.send( route.method, ProxyHelper.replace_path_attributes(options, route.path), route.options)
          route.valid_response(response)
          response
        end

        def find! options = {}
          begin
            find(options)
          rescue ActiveRest::Error::ResponseError => e
            nil
          end
        end
      end
    end
  end
end