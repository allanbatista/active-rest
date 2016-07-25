module ActiveRest
  class Route
    attr_reader :path, :method, :success, :headers, :options

    def initialize path, method, success = 200..299, headers = {}, options = {}
      @path    = path
      @method  = method
      @success = success
      @headers = headers || {}
      @options = options || {}
    end

    def success? status
      success_a.include?(status)
    end

    def valid_response response
      raise ActiveRest::Error.by_response(response) unless success?(response.status)
    end

    private
      def success_a
        if @success_a
          @success_a
        else
          arr = success
          arr = success.to_a if success.is_a? Range
          arr = [arr] unless arr.is_a? Array
          @success_a = arr
        end
      end
  end
end