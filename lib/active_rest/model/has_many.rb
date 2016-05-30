module ActiveRest
  module Model
    module HasMany
      extend ActiveSupport::Concern

      included do
        def self.has_many field_name, options = {}
          class_name = options[:class_name]
          class_name = field_name.to_s.classify if class_name.nil?

          type = options[:type]
          type = String if type.nil?
          clazz = class_name.constantize

          define_method field_name do
            Iterator.new(clazz, { post: self })
          end
        end
      end

    end
  end
end