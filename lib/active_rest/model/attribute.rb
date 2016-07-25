module ActiveRest
  module Model
    class Attribute
      attr_reader :name, :type, :default, :remote_name, :remote_type, :as

      def initialize name, options = {}
        @name        = name
        @type        = options.fetch(:type, String)
        @default     = options.fetch(:default, nil)
        @remote_name = options.fetch(:remote_name, @name)
        @remote_type = options.fetch(:remote_type, @type)
        @as          = options.fetch(:as, nil)
      end

      def to_local value
        normalize(@type, value, :local)
      end

      def to_remote value
        normalize(@remote_type, value, :remote)
      end

      private
        def normalize type, value, to
          return @default if value.nil?
          
          if type == String
            value.to_s
          elsif type == Integer
            value.to_i
          elsif type == Float
            value.to_f
          elsif type == Array && !@as.nil?
            value.map do |val|
              if to == :local
                obj = @as.new
                obj.from_remote(val)
                obj
              else
                if @as.nil?
                  val
                else
                  val.to_remote
                end
              end
            end
          else
            value
          end
        end
    end
  end
end