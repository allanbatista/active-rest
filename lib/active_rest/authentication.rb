module ActiveRest
  class Authentication
    attr_reader :connection, :options

    def initialize connection, options = {}
      @options    = options
      @connection = connection
    end

    ##
    # should be return boolean
    def authenticate! path = nil, params = nil, headers = nil
      raise NotImplementedError
    end
  end
end