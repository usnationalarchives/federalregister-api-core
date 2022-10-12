class ApplicationSearch::Filter
  attr_reader :value, :condition, :label, :es_type, :es_attribute, :es_value, :name, :multi, :date_selector, :range_conditions
  def initialize(options)
    @name               = options[:name]
    @value              = [options[:value]].flatten
    @condition          = options[:condition]
    @es_attribute   = options[:es_attribute] || @condition

    @model_class        = options[:model_class]
    @model_id_method    = options[:model_id_method] || :id
    @model_label_method = options[:model_label_method] || :name

    @multi              = options[:multi] || false

    @date_selector      = options[:date_selector] || false
    @range_conditions   = options[:range_conditions] || false

    unless @name
      @name_definer = options[:name_definer] ||= Proc.new do |*ids|
        ids.flatten.map{|id|
          begin
            model_class.send("find_by_#{@model_id_method}!", id)
          rescue
            raise EsApplicationSearch::InputError.new("invalid value")
          end
        }.
        compact.
        map{|x| x.send(@model_label_method)}.
        to_sentence(:two_words_connector => ' or ', :last_word_connector => ', or ')
      end

      @name = @name_definer.call(@value)
    end

    if options[:es_value_processor]
      @es_value = options[:es_value_processor].call(options[:value])
    elsif options[:phrase]
      @es_value = options[:value]
    elsif options[:model_es_method]
      @es_value = @value.map{|id|
        begin
          model_class.send("find_by_#{@model_id_method}!", id)
        rescue
          raise EsApplicationSearch::InputError.new("invalid value")
        end
      }.map{|x| x.send(options[:model_es_method])}.first
    elsif options[:es_value_processor]
      @es_value = options[:es_value_processor].call(options[:value])
    else
      @es_value = options[:value]
    end
    @es_type  = options[:es_type] || :conditions
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
