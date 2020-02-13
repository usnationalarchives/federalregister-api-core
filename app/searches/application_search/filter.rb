class ApplicationSearch::Filter
  attr_reader :value, :condition, :label, :sphinx_type, :sphinx_attribute, :sphinx_value, :name, :multi, :date_selector
  def initialize(options)
    @name               = options[:name]
    @value              = [options[:value]].flatten
    @condition          = options[:condition]
    @sphinx_attribute   = options[:sphinx_attribute] || @condition

    @model_class        = options[:model_class]
    @model_id_method    = options[:model_id_method] || :id
    @model_label_method = options[:model_label_method] || :name

    @multi              = options[:multi] || false

    @date_selector      = options[:date_selector] || false

    unless @name
      @name_definer = options[:name_definer] ||= Proc.new do |*ids|
        ids.flatten.map{|id|
          begin
            model_class.send("find_by_#{@model_id_method}!", id)
          rescue
            raise ApplicationSearch::InputError.new("invalid value")
          end
        }.
        compact.
        map{|x| x.send(@model_label_method)}.
        to_sentence(:two_words_connector => ' or ', :last_word_connector => ', or ')
      end

      @name = @name_definer.call(@value)
    end

    if options[:es_value_processor]
      @sphinx_value = options[:es_value_processor].call(options[:value])
    elsif options[:phrase]
      @sphinx_value = "\"#{@value.join(' ')}\""
    elsif options[:crc32_encode]
      @sphinx_value = @value.map{|v| Zlib.crc32(v.to_s) }.first
    elsif options[:model_sphinx_method]
      @sphinx_value = @value.map{|id|
        begin
          model_class.send("find_by_#{@model_id_method}!", id)
        rescue
          raise ApplicationSearch::InputError.new("invalid value")
        end
      }.map{|x| x.send(options[:model_sphinx_method])}.first
    elsif options[:sphinx_value_processor]
      @sphinx_value = options[:sphinx_value_processor].call(options[:value])
    else
      @sphinx_value = options[:value]
    end
    @sphinx_type  = options[:sphinx_type] || :conditions
    @label        = options[:label] || @condition.to_s.singularize.humanize
  end

  def model_class
    @model_class || @condition.
                      to_s.
                      sub(/_ids?$/,'').
                      classify.
                      constantize
  end
end
