module ActiveRest
  module Model
    module BelongsTo
      extend ActiveSupport::Concern

      included do
        def self.belongs_to field_name, options = {}
          class_name = options[:class_name]
          class_name = field_name.to_s.classify if class_name.nil?

          type = options[:type]
          type = String if type.nil?

          attribute_name = "#{field_name}_id".to_sym

          self.field attribute_name, type: type

          instance_variable_set( "@#{field_name}", nil)

          ##
          # Getter
          define_method field_name do
            clazz = class_name.constantize
            
            if instance_variable_get( "@#{field_name}")
              instance_variable_get( "@#{field_name}")
            else
              object = clazz.find({ id: instance_variable_get( "@#{attribute_name}") })
              instance_variable_set( "@#{field_name}", object)
              instance_variable_get( "@#{field_name}")
            end
          end

          ##
          # Setter
          define_method "#{field_name}=" do |object|
            instance_variable_set( "@#{field_name}", object)
            instance_variable_set( "@#{attribute_name}", object.id)
          end
        end
      end

    end
  end
end