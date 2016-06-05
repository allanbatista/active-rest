module ActiveRest
  class Iterator
    attr_reader :model, :limit, :offset, :options

    def initialize model, options = {}
      @options = options
      @model  = model
      @limit  = 20
      @offset = 1
    end

    def limit limit = nil
      unless limit.nil?
        @limit = limit
        self
      else
        @limit
      end
    end

    def offset offset = nil
      unless offset.nil?
        @offset = offset
        self
      else
        @offset
      end
    end

    def each
      loop do
        itens = next_itens

        itens.each { |item| yield(item) }

        break if itens.empty? || itens.size < @limit
      end
    end

    def to_a
      array = []

      loop do
        itens = next_itens

        array += itens
        
        break if itens.empty? || itens.size < @limit
      end

      array
    end

    private
      def next_itens
        response = @model.proxy.list(@limit, @offset, options)
        @offset += 1
        @model.parse_and_initialize(:list, response.body)
      end
  end
end