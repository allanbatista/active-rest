module ActiveRest
  module Model
    module Field
      extend ActiveSupport::Concern

      def initialize attrs = {}
        attrs.keys.each { |key| self.send("#{key}=", attrs[key]) }
      end

      def changes
        @changes ||= {}
      end

      def initialize_defaults
        self.class.attributes.each do |attribute_name, attribute|
          instance_variable_set( "@#{attribute_name}", attribute.default )
        end
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

        self.class.attributes.each do |attribute_name, attribute|
          hash[attribute.remote_name] = attribute.to_remote(self.send(attribute.name))
        end

        ActiveRest::Utils::Hash.keys_to_s(hash)
      end

      def from_remote hash
        return self unless hash.is_a? Hash

        self.class.attributes.each do |attribute_name, attribute|
          send("#{attribute_name}=", hash[attribute.remote_name.to_s])
        end

        self
      end

      def attributes
        self.class.attributes
      end

      def copy_from model
        attributes.keys.each { |att| self.send("#{att}=", model.send(att)) }
      end

      included do

        def self.attributes
          @attributes ||= {}
        end

        def self.field attribute_name, options = {}
          attributes[attribute_name] = Attribute.new(attribute_name, options)

          ##
          # Create getter method
          define_method attribute_name do
            instance_variable_get("@#{attribute_name}")
          end

          ##
          # Create setter method
          define_method "#{attribute_name}=" do |new_value|
            current_value = instance_variable_get("@#{attribute_name}")
            new_value = self.class.attributes[attribute_name].to_local(new_value)
            changes[attribute_name] = [new_value, current_value] if current_value != new_value
            instance_variable_set( "@#{attribute_name}", new_value )
          end
        end
      end
    end
  end
end