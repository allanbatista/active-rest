module ActiveRest
  class Proxy
    module Update
      extend ActiveSupport::Concern

      included do
        def update model
          route = routes[:update]
          response = method_with_body(route, model)
          route.valid_response(response)
          response
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