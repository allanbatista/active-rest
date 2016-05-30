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
        response = @model.proxy.list(@limit, @offset, options)
        itens    = @model.parse_and_initialize(response)

        break if itens.empty?
        @offset += 1
        itens.each { |item| yield(item) }
      end
    end

    def to_a
      array = []

      loop do
        response = @model.proxy.list(@limit, @offset, options)
        itens    = @model.parse_and_initialize(response)

        break if itens.empty?
        @offset += 1
        array += itens
      end

      array
    end
  end
end