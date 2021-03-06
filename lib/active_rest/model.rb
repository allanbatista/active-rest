module ActiveRest
  module Model
    extend  ActiveSupport::Concern

    include ActiveRest::Model::Field
    include ActiveRest::Model::Initialize
    include ActiveRest::Model::Error
    include ActiveRest::Model::Proxy
    include ActiveRest::Model::BelongsTo
    include ActiveRest::Model::HasMany

    ##
    # Faz um fetch no servidor e recarrega o objeto atual
    def reload
      model = self.class.find(to_remote)

      if model.errors?
        add_errors(model.errors)
      else
        copy_from(model)
        persist!
      end

      self
    end

    ##
    # Deve persistir o objeto
    def save
      raise StandardError.new("Modelo removido") if destroyed?

      clear_errors

      begin
        if persisted?
          self.class.proxy.update(self)
          action_name = :update
        else
          self.class.proxy.create(self)
          action_name = :create
        end

        persist!

        true
      rescue ActiveRest::Error::ResponseError => e
        add_errors(self.class.parse_error(e.response))
        false
      end
    end

    def destroy
      begin
        self.class.proxy.destroy(self)
        true
      rescue => e
        add_errors(self.class.parse_error(e.response))
        false
      end
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

    def destroyed!
      @destroyed = true
    end

    def destroyed?
      @destroyed || false
    end

    included do
      def self.all
        Iterator.new( self )
      end

      def self.list options = {}
        Iterator.new(self, options)
      end

      def self.find options
        response = proxy.find(options)
        parse_and_initialize(:find, response.body)
      end

      def self.find_or_initialize options
        find(options) || self.new(options)
      end

      def self.connection connection = @connection
        @connection = connection
      end

      def self.parse_and_initialize action, body
        parsed = parse(action, body)
        return initialize_many_from_remote(parsed) if parsed.is_a? Array
        return initialize_from_remote(parsed)
      end

      def self.initialize_from_remote hash
        return nil if hash.nil?
        model = self.new
        model.from_remote(hash)
        model.persist!
        model
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