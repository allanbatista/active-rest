module ActiveRest
  module Model
    module Field
      extend ActiveSupport::Concern

      def changes
        @changes ||= {}
      end

      included do
        def self.attributes
          @attributes ||= {}
        end

        def self.field attribute_name, options = {}
          options = options.merge({ type: String })
          attributes[attribute_name] = options

          instance_variable_set( "@#{attribute_name}", attributes[attribute_name][:default] )

          define_method attribute_name do
            instance_variable_get("@#{attribute_name}")
          end

          define_method "#{attribute_name}=" do |new_value|
            current_value = instance_variable_get("@#{attribute_name}")
            changes[attribute_name] = [new_value, current_value] if current_value != new_value
            instance_variable_set( "@#{attribute_name}", new_value )
          end
        end
      end
    end
  end
end