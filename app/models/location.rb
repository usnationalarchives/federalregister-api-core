class Location
  attr_accessor :text, :longitude, :country_code, :country_name, :area_code, :city, :region, :latitude, :country_code, :dma_code
  
  def initialize(options={})
    options.each_pair do |key, value|
      if respond_to?("#{key}=")
        self.send("#{key}=", value)
      end
    end
  end
  
  def name
    "#{city}, #{region}"
  end
end