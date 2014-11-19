class ApplicationSearch::Facet
  attr_reader :value, :name, :condition, :count, :on

  def initialize(options)
    @value      = options[:value]
    @name       = options[:name]
    @condition  = options[:condition]
    @count      = options[:count]
    @on         = options[:on]
    @identifier = options[:identifier]
  end
  
  def on?
    @on
  end

  def identifier
    @identifier || @value
  end
end
