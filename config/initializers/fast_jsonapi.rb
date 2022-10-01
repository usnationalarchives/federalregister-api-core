#NOTE: This is a modification of the fast_jsonapi gem that allows us to save metadata options like :includes or :selects on an attribute like we used to on the old ApiRepresentation classes.

module FastJsonapi
  class Attribute
    attr_reader :key, :method, :conditional_proc, :options

    def initialize(key:, method:, options: {})
      @key = key
      @method = method
      @conditional_proc = options[:if]
      @options = options
    end

  end
end
