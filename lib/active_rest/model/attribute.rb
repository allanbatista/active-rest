module ActiveRest
  module Model
    class Attribute
      attr_reader :name, :type, :default, :remote_name, :remote_type

      def initialize name, options = {}
        @name        = name
        @type        = options.fetch(:type, String)
        @default     = options.fetch(:default, nil)
        @remote_name = options.fetch(:remote_name, @name)
        @remote_type = options.fetch(:remote_type, @type)
      end

      def to_local value
        normalize(@type, value)
      end

      def to_remote value
        normalize(@remote_type, value)
      end

      private
        def normalize type, value
          return @default if value.nil?

          if type == String
            value.to_s
          elsif type == Integer
            value.to_i
          elsif type == Float
            value.to_f
          else
            value
          end
        end
    end
  end
end