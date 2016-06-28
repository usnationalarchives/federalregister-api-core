require 'spec_helper'

describe LocationCacher do
  include RedisSpecHelperMethods
  use_vcr_cassette

  def clear_redis_cache_key(key)
    redis.del(key) #TODO: Make sure this is clearing the correct redis test db.
  end

  describe "#perform" do
    it "returns an empty Geokit::GeoLoc object if a zip code is not provided" do
      cacher = LocationCacher.new('bad_string')

      result = cacher.perform

      result.should == Geokit::GeoLoc.new
    end

    it "returns the correct geolocation data" do
      cacher = LocationCacher.new('94118')

      result = cacher.perform

      result.city.should == "San Francisco"

      clear_redis_cache_key(cacher.send(:redis_key))
    end

  end

end
