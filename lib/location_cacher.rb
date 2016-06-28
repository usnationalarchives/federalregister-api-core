class LocationCacher

  ZIP_CODE_REGEX  = Regexp.new('^\d{5}(?:[-\s]\d{4})?$')
  REDIS_NAMESPACE = "location"

  def self.perform(location_string)
    new(location_string).perform
  end

  def initialize(location_string)
    @location_string = location_string.strip
  end

  def perform
    if valid_string?
      geolocation
    else
      empty_geolocation
    end
  end

  private

  attr_reader :location_string

  def valid_string?
    location_string =~ ZIP_CODE_REGEX
  end

  def geolocation
    value = redis.get(redis_key)

    if value
      stored_location = Geokit::GeoLoc.new(JSON.parse(value))
    else
      stored_location = nil
    end

    if stored_location && stored_location.lat && stored_location.long
      stored_location
    else
      cache_location!
    end
  end

  def cache_location!
    redis.set(redis_key, geocoder_result.to_hash.to_json)
    redis.expire(redis_key, 1209600)

    geocoder_result
  end

  def redis_key
    "#{REDIS_NAMESPACE}:#{location_string}"
  end

  def geocoder_result
    @geocoder_result ||= Geokit::Geocoders::GoogleGeocoder.geocode(location_string)
  end

  def empty_geolocation
    Geokit::GeoLoc.new
  end

  def redis
    @redis ||= Redis.new
  end

end
