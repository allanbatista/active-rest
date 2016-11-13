module ActiveRest
  class Proxy
    module Update
      extend ActiveSupport::Concern

      included do
        def update model
          route = routes[:update]
          response = method_with_body(route, model)
          route.valid_response(response)
          model.from_remote(model.class.parse(:update, response.body))
        end

        def update! model
          begin
            update(model)
          rescue ActiveRest::Error::ResponseError => e
            model
          end
        end
      end
    end
  end
end