class ApplicationSerializer
  extend Rails.application.routes.url_helpers
  extend RouteBuilder
  extend Routeable

  include FastJsonapi::ObjectSerializer
  #cache_options enabled: true, cache_length: 1.hour

  def to_h
    data = serializable_hash

    if data[:data].is_a? Hash
      data[:data][:attributes]

    elsif data[:data].is_a? Array
      data[:data].map{ |x| x[:attributes] }

    elsif data[:data] == nil
      nil

    else
      data
    end
  end

  def self.find_options_for(*fields)
    selects = [:id, :raw_text_updated_at]
    includes = []

    api_fields_set = api_fields.to_set
    attributes_by_name = self.attributes_to_serialize

    fields.flatten.each do |field|
      raise FieldNotFound.new("field '#{field}' not valid") unless api_fields_set.include? field
      options = attributes_by_name[field].options
      if options.blank?
        options = {:select => field}
      end
        
      selects  << options[:select]  if options[:select]
      includes << options[:include] if options[:include]
    end

    {:select => selects.flatten.uniq.join(', '), :include => includes.flatten.uniq}
  end

  class << self
    def has_one resource, options={}
      serializer = options[:serializer] || "#{resource.to_s.classify}Serializer".constantize

      attribute resource do |object|
        serializer.new(object.try(resource)).to_h
      end
    end

    def has_many resources, options={}
      serializer = options[:serializer] || "#{resources.to_s.classify}Serializer".constantize

      attribute resources do |object|
        serializer.new(object.try(resources)).to_h
      end
    end
  end
end
