require 'spec_helper'

describe GeoLocator do
  include RedisSpecHelperMethods
  use_vcr_cassette

  describe ".perform" do
    it "returns an empty Geokit::GeoLoc object if a zip code is not provided" do
      result= GeoLocator.perform('bad_string')
      result.should == Geokit::GeoLoc.new
    end

    it "returns the correct geolocation data" do
      result = GeoLocator.perform('94118')
      result.city.should == "San Francisco"
    end

    describe "with an invalid location cached" do
      it "will replace a location value if the cached value returns nil for the lat" do
        GeoLocator.new('02108').send(:cache_location, {lat: nil, lng: 90.01234})

        result = GeoLocator.perform('02108')
        result.city.should == "Boston"
      end

      it "will replace a location value if the cached value returns nil for the lng" do
        GeoLocator.new('02108').send(:cache_location, {lat: 90.01234, lng: nil})

        result = GeoLocator.perform('02108')
        result.city.should == "Boston"
      end
    end
  end
end
