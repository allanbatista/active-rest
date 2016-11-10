module ActiveRest
  ##
  # Proxy should abstract how interact with model with api.
  class Proxy
    include List
    include Find
    include Create
    include Update
    include Destroy

    attr_reader :model, :routes

    def initialize model
      @model  = model
    end

    def routes
      @routes ||= {}
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