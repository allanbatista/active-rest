module ActiveRest
  class Proxy
    module Create
      extend ActiveSupport::Concern

      included do
        def create model
          route = routes[:create]
          response = method_with_body(route, model)
          route.valid_response(response)
          model.from_remote(model.class.parse(:update, response.body))
        end

        def create! model
          begin
            create(model)
          rescue ActiveRest::Error::ResponseError => e
            model
          end
        end
      end
    end
  end
end