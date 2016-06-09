module ActiveRest
  module Model
    module Initialize
      extend  ActiveSupport::Concern
      
      def initialize attrs = {}
        attrs.keys.each { |key| self.send("#{key}=", attrs[key]) }
      end

      included do
  	    def self.new(*args, &block)
  	      obj = self.allocate
  	      obj.initialize_defaults
  	      obj.send(:initialize, *args, &block)
  	      obj
  	    end
      end
		end
	end
end