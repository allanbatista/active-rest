module ActiveRest
  class Proxy
    module Destroy
      extend ActiveSupport::Concern

      included do
        def destroy model
          route  = routes[:destroy]
          response = @model.connection.send( route.method, ProxyHelper.replace_path_attributes(model, route.path), route.options)
          route.valid_response(response)
          model.destroyed!
          model.class.proxy.routes[:destroy].success?(response.status)
        end

        def destroy! model
          begin
            create(model)
          rescue ActiveRest::Error::ResponseError => e
            nil
          end
        end
      end
    end
  end
end