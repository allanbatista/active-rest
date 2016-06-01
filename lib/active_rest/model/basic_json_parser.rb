require 'json'

module ActiveRest
  module Model
    module BasicJsonParser
      extend ActiveSupport::Concern

      included do
        def self.parse action, body
          return nil if body.to_s == ''
          JSON.parse(body)
        end
      end
    end
  end
end