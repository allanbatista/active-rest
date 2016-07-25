require 'active_rest/utils/hash'

module ActiveRest
  module Utils
    module Hash
      def self.keys_to_s hash
        ::Hash[hash.map{|(k,v)| [k.to_s,v]}]
      end
    end
  end
end