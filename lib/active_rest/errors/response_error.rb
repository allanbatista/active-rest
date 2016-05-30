module ActiveRest
  module Error
    class ResponseError < StandardError
      attr_reader :response

      def initialize response
        @response = response
        super( ActiveRest::Response.messages(response.status) )
      end
    end
  end
end