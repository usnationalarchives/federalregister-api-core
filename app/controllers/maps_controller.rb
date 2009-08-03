class MapsController < ApplicationController
  include Locator
  include Cloudkicker
  
  def index
    @user_location = remote_location
    lat  = @user_location.latitude
    long = @user_location.longitude
    @places = Place.find_near([lat,long])
    
    @map = Cloudkicker::Map.new( :lat      => lat, 
                                 :long     => long,
                                 :zoom     => 8,
                                 :style_id => 1714
                                )
    @places.each do |place|
      Cloudkicker::Marker.new( :map   => @map, 
                               :lat   => place.latitude,
                               :long  => place.longitude, 
                               :title => place.entry_list
                             )
    end
  end
end