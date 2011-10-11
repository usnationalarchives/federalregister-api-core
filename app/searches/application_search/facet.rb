class ApplicationSearch::Facet
  attr_reader :value, :name, :condition, :count, :on

  def initialize(options)
    @value      = options[:value]
    @name       = options[:name]
    @condition  = options[:condition]
    @count      = options[:count]
    @on         = options[:on]
  end
  
  def on?
    @on
  end
end
