module ActiveRest
  module Model
    module Error
      extend ActiveSupport::Concern

      def errors?
        errors.any?
      end

      def errors
        @errors ||= []
      end

      def add_error message
        errors << message
      end

      def add_errors messages
        messages.each { |message| add_error(message) }
      end

      def clear_errors
        errors = []
      end

      included do
        def self.parse_error response
          errors = []

          errors << ActiveRest::Response.messages(response.status)
          errors << response.body if response.body.to_s.strip != ''

          errors
        end
      end
    end
  end
end