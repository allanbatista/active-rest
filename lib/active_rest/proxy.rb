module ActiveRest
  class Proxy
    include List

    attr_reader :model, :routes

    def initialize model
      @model  = model
    end

    def routes
      @routes ||= {}
    end

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

    def create model
      route = routes[:create]
      response = method_with_body(route, model)
      route.valid_response(response)
      response
    end

    def create! model
      begin
        create(model)
      rescue ActiveRest::Error::ResponseError => e
        model
      end
    end

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

    def destroy model
      route  = routes[:destroy]
      response = @model.connection.send( route.method, ProxyHelper.replace_path_attributes(model, route.path), route.options)
      route.valid_response(response)
      response
    end

    def destroy! model
      begin
        create(model)
      rescue ActiveRest::Error::ResponseError => e
        nil
      end
    end

    private
      def method_with_body route, model
        body = model.to_remote
        body = body.slice(*model.changes.keys) if route.method == :patch

        if route.options[:data_type] == :json
          body = body.to_json
          route.headers = { 'Content-Type' => 'application/json' }.merge(route.headers)
        end

        @model.connection.send(
          route.method,
          ProxyHelper.replace_path_attributes(model, route.path),
          body,
          route.headers
        )
      end
  end
end