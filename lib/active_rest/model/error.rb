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

    end
  end
end