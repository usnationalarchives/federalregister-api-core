class ApplicationSearch
  class PlaceSelector
    extend Memoist
    DEFAULT_WITHIN = 25
    attr_accessor :location, :within
    attr_reader :validation_errors

    def initialize(location, within = DEFAULT_WITHIN)
      @location = location.to_s
      @validation_errors = ''

      @within = DEFAULT_WITHIN
      if within.present? && within.is_a?(String) || within.is_a?(Integer)
        if within.to_i < 1 || within.to_i > 200
          @validation_errors = "within must be between 1 and 200"
        else
          @within = within.to_i
        end
      end
    end

    def valid?
      place_ids
      @validation_errors.empty?
    end

    def place_ids
      if @validation_errors.empty? && location.present?
        @place_ids ||= Place.select("id").within(within, origin: location_latlong).map(&:id)

        if @place_ids.size > 4096
          @validation_errors = 'We found too many places near your location; try limiting the radius of the search'
        end

        @place_ids
      end
    end

    private

    def location_latlong
      if geoapify_location
        geoapify_location.coordinates
      else
        @validation_errors = "We could not understand your location, '#{location}'. Location must be a valid postal code."
      end
    end

    def geoapify_location
      Geocoder.
        search(location).
        sort_by{|x| x.country == "United States" ? 0 : 1}. #ie prioritize US postal codes.  Geoapify supports postal countries from other countries as well
        first
    end
    memoize :geoapify_location

  end
end
