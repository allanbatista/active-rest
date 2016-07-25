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

    def create obj
      route = routes[:create]
      response = method_with_body(route, obj)
      route.valid_response(response)
      response
    end

    def update obj
      route = routes[:update]
      response = method_with_body(route, obj)
      route.valid_response(response)
      response
    end

    def destroy obj
      route  = routes[:destroy]
      response = @model.connection.send( route.method, ProxyHelper.replace_path_attributes(obj, route.path), route.options)
      route.valid_response(response)
      response
    end

    private
      def method_with_body route, obj
        body = obj.to_remote
        body = body.slice(*obj.changes.keys) if route.method == :patch

        if route.options[:data_type] == :json
          body = body.to_json
          route.headers = { 'Content-Type' => 'application/json' }.merge(route.headers)
        end

        @model.connection.send(route.method, ProxyHelper.replace_path_attributes(obj, route.path), body, route.headers)
      end
  end
end