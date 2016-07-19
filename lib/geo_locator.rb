class GeoLocator

  ZIP_CODE_REGEX  = Regexp.new('^\d{5}(?:[-\s]\d{4})?$')
  REDIS_NAMESPACE = "location"
  REDIS_EXPIRES_IN = 1.day.to_i

  attr_reader :location_string

  def self.perform(location_string)
    new(location_string).perform
  end

  def initialize(location_string)
    @location_string = location_string.strip
  end

  def perform
    valid_string? ? geolocation : empty_geolocation
  end

  private

  def valid_string?
    location_string =~ ZIP_CODE_REGEX
  end

  def geolocation
    cached_location = redis.get(redis_key)
    geo_location = cached_location ? Geokit::GeoLoc.new(JSON.parse(cached_location)) : nil
    valid_location?(geo_location) ? geo_location : geolocate
  end

  def empty_geolocation
    Geokit::GeoLoc.new
  end

  def valid_location?(location)
    location && location.lat && location.long
  end

  def geolocate
    cache_location(geocode)
    geocode
  end

  def cache_location(location)
    # TODO: BB use a single call once we've upgraded redis gem
    redis.set(redis_key, location.to_hash.to_json)
    redis.expire(redis_key, REDIS_EXPIRES_IN)
  end

  def redis_key
    "#{REDIS_NAMESPACE}:#{location_string}"
  end

  def geocode
    @geocode ||= Geokit::Geocoders::GoogleGeocoder.geocode(location_string)
  end

  def redis
    @redis ||= Redis.new
  end
end
