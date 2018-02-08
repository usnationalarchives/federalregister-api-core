class ApiRepresentation
  class FieldNotFound < StandardError; end

  class << self
    extend ActiveSupport::Memoizable

    # don't ask...
    class << self.class
      def default_url_options
        case Rails.env
        when 'development'
          {:host => "dev-fr2.criticaljuncture.org", :protocol => "https"}
        when 'test'
          {:host => "www.fr2.local", :port => 8081, :protocol => "http"}
        when 'staging'
          {:host => "fr2.criticaljuncture.org", :protocol => "https"}
        else
          {:host => "www.federalregister.gov", :protocol => "https"}
        end
      end
    end

    include ActionController::UrlWriter
    include ApplicationHelper
    include RouteBuilder

    attr_accessor :default_index_fields_json, :default_index_fields_csv, :default_index_fields_rss

    def field(name, options = nil, &calculator)
      options ||= {:select => name}
      calculator ||= Proc.new{|obj| obj.send(name)}

      @field_options ||= {}
      @field_calculators ||= {}

      @field_options[name] = options
      @field_calculators[name] = calculator
    end

    def find_options_for(*fields)
      selects = [:id]
      includes = []

      fields.flatten.each do |field|
        options = @field_options[field]
        raise FieldNotFound.new("field '#{field}' not valid") unless options
        selects  << options[:select]  if options[:select]
        includes << options[:include] if options[:include]
      end

      {:select => selects.flatten.uniq.join(', '), :include => includes.flatten.uniq}
    end
    memoize :find_options_for

    def all_fields
      @all_fields ||= @field_calculators.keys.sort_by{|v| v.to_s}
    end

    def field_calculators
      @field_calculators
    end
  end

  def initialize(obj)
    @obj = obj
  end

  def value(field)
    field_calculator_for(field).call(@obj)
  end

  private

  def field_calculator_for(field)
    calculator = self.class.field_calculators[field]
    raise FieldNotFound.new("field '#{field}' not valid") unless calculator.present?
    calculator
  end
end
