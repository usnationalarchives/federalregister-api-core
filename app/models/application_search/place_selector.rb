class ApplicationSearch
  class PlaceSelector
    DEFAULT_WITHIN = 25
    attr_accessor :location, :within
    attr_reader :validation_errors
    
    def initialize(location, within = DEFAULT_WITHIN)
      @location = location
      @validation_errors = ''
      
      if within.present?
        if within.to_i < 1 || within.to_i > 200
          @validation_errors = "within must be between 1 and 200"
        else
          @within = within.to_i || DEFAULT_WITHIN
        end
      end
    end
    
    def valid?
      place_ids
      @validation_errors.empty?
    end
    
    def place_ids
      if @validation_errors.empty?
        @place_ids ||= Place.find(:all, :select => "id", :origin => location_latlong, :within => within).map(&:id)
        
        if @place_ids.size > 4096
          @validation_errors = 'We found too many places near your location; try limiting the radius of the search'
        end
        
        @place_ids
      end
    end
    
    private
    
    def location_latlong
      latlong = Rails.cache.fetch("location_of: '#{location}'") { Geokit::Geocoders::GoogleGeocoder.geocode(location) }
      
      if latlong.lat.blank? || latlong.lng.blank?
        @validation_errors = "We could not understand your location"
      end
      
      latlong
    end
  end
end