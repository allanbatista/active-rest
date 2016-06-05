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
      clear_errors

      begin
        if persisted?
          response = self.class.proxy.update(self)
          action_name = :update
        else
          response = self.class.proxy.create(self)
          action_name = :create
        end

        from_remote(self.class.parse(action_name, response.body))
        self.class.proxy.routes[action_name].success?(response.status)
      rescue ActiveRest::Error::ResponseError => e
        add_errors(self.class.parse_error(e.response))
        false
      end
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
      return self if hash.nil?

      self.class.attributes.keys.each do |attribute|
        send("#{attribute}=", hash[( self.class.attributes[attribute][:remote_name] || attribute ).to_s])
      end

      persist!

      self
    end

    def persist!
      @persisted = true
    end

    def unpersist!
      @persisted = false
    end

    def persisted?
      @persisted || false
    end

    included do

      def self.parse action, body
        raise NotImplementedError.new
      end

      def self.parse_and_initialize action, body
        parsed = parse(action, body)
        return initialize_many_from_remote(parsed) if parsed.is_a? Array
        return initialize_from_remote(parsed)
      end

      def self.all
        Iterator.new( self )
      end

      def self.find options
        response = proxy.find(options)
        parse_and_initialize(:find, response.body)
      end

      def self.connection connection = @connection
        @connection = connection
      end

      def self.initialize_from_remote hash
        return nil if hash.nil?
        model = self.new
        model.from_remote(hash)
      end

      def self.initialize_many_from_remote array
        array.map { |item| self.initialize_from_remote(item)  }
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