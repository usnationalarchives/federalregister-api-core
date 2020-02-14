class ApplicationSerializer
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
