module ActiveRest
  module Model
    extend ActiveSupport::Concern
    
    include ActiveRest::Model::Field
    include ActiveRest::Model::Error
    include ActiveRest::Model::Proxy
    include ActiveRest::Model::BelongsTo
    include ActiveRest::Model::HasMany

    def initialize attrs = {}
      attrs.keys.each { |key| self.send("#{key}=", attrs[key]) }
    end

    ##
    # Faz um fetch no servidor e recarrega o objeto atual
    def reload
      obj = self.class.find(to_remote)

      if obj.nil?
        self.add_error(Response.messages(404))        
      elsif obj.errors?
        self.add_errors(obj.errors)
      else
        self.class.attributes.keys.each do |attribute|
          self.send("#{attribute}=", obj.send(attribute))
        end
      end

      self
    end

    ##
    # Deve persistir o objeto
    def save
      if id.nil?
        response = self.class.proxy.create(self)
        action_name = :create
      else
        response = self.class.proxy.update(self)
        action_name = :update
      end

      from_remote(self.class.parse(response))
      self.class.proxy.routes[action_name].success?(response.status)
    end

    def destroy
      response = self.class.proxy.destroy(self)
      self.class.proxy.routes[:destroy].success?(response.status)
    end

    ##
    # Gera um Hash que corresponde a estrutura remota do recurso na API.
    #
    # Exemplo:
    #
    #     object = User.new
    #     object.to_remote #=> {"name"=>"Allan"}
    def to_remote
      hash = {}

      self.class.attributes.keys.each do |attribute_name|
        attribute = self.class.attributes[attribute_name]
        hash[( attribute[:remote_name] || attribute_name ).to_s] = self.send(attribute_name)
      end

      hash
    end

    def from_remote hash
      self.class.attributes.keys.each do |attribute|
        send("#{attribute}=", hash[( self.class.attributes[attribute][:remote_name] || attribute ).to_s])
      end

      self
    end

    included do

      def self.parse response
        return {} if [nil, ''].include?(response.body)
        Parser.parse(parser, response.body)
      end

      def self.parse_and_initialize response
        parsed = parse(response)
        return initialize_many_from_remote(parsed, response) if parsed.is_a? Array
        return initialize_from_remote(parsed, response)
      end

      def self.parser parser = nil
        @parser = parser unless parser.nil?
        @parser
      end

      def self.all
        Iterator.new( self )
      end

      def self.find options
        response = proxy.find(options)
        parse_and_initialize(response)
      end

      def self.build_error_message response
        MESSAGES[response.status] || "Error on API with status #{response.status} and body: \n#{response.body}"
      end

      def self.connection connection = @connection
        @connection = connection
      end

      def self.initialize_from_remote hash, response
        model = self.new
        model.from_remote(hash)
        model if hash.any?
      end

      def self.initialize_many_from_remote array, response
        array.map { |item| self.initialize_from_remote(item, response)  }
      end

      def self.limit limit = @limit
        @limit = limit unless limit.nil?
        @limit
      end

      def self.offset offset = 1
        @offset = offset unless offset.nil?
        @offset
      end
    end
  end
end