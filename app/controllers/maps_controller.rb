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
                               :title => 'Click to display entries for this location.'
                               #render_to_string(:partial => 'entry_marker_tooltip', :locals => {:place => place} )
                             )
    end
  end
end