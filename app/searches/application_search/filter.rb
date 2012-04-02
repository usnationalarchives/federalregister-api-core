class ApplicationSearch::Filter
  attr_reader :value, :condition, :label, :sphinx_type, :sphinx_attribute, :sphinx_value
  def initialize(options)
    @value        = options[:value]
    @name         = options[:name]
    @name_definer = options[:name_definer]
    @condition    = options[:condition]
    @sphinx_attribute = options[:sphinx_attribute] || @condition
    
    if options[:phrase]
      @sphinx_value = "\"#{options[:value]}\""
    elsif options[:crc32_encode]
      @sphinx_value = options[:value].map{|v| v.to_s.to_crc32}
    elsif options[:sphinx_value_processor]
      @sphinx_value = options[:sphinx_value_processor].call(options[:value])
    else
      @sphinx_value = options[:value]
    end
    @sphinx_type  = options[:sphinx_type] || :conditions
    @label        = options[:label] || @condition.to_s.singularize.humanize
  end
  
  def name
    @name ||= @name_definer.call(value)
  end
end
