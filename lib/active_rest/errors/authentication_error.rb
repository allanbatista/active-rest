module ActiveRest
  module Error
    class AuthenticationError < StandardError
      attr_reader :path, :params, :headers
      
      def initialize message, options = {}
        super(message)
        @path = options[:path]
        @params = options[:params]
        @headers = options[:headers]
      end
    end
  end
end