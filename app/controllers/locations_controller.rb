class LocationsController < ApplicationController
  def edit
    @location = Location.new
  end
  
  def update
    location_text = params[:location][:text]
    
    location = Geokit::Geocoders::GoogleGeocoder.geocode(location_text)
    # raise location.inspect
  end
end