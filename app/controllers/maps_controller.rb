class MapsController < ApplicationController
  include Locator
  def index
    @user_location = remote_location
    lat  = @user_location.latitude
    long = @user_location.longitude
    @places = Place.find_near([lat,long])
    @map = GoogleMap::Map.new
    #@map.bounds =  [GoogleMap::Point.new(47.6597, -121.318), GoogleMap::Point.new(48.6597, -123.318)] #SEATTLE WASHINGTON 50KM
    @places.each do |place|
      @map.markers << GoogleMap::Marker.new( :map => @map, 
                                             :lat => place.latitude,
                                             :lng => place.longitude,
                                             :html => place.entry_list
                                           )
    end
  end
end