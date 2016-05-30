require 'json'

module ActiveRest
  module Parser
    module Json
      def self.parse json
        JSON.parse(json)
      end
    end
  end
end