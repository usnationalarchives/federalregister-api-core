class MapsController < ApplicationController
  include Locator
  include Cloudkicker
  
  def index
    @location = remote_location
    @lat  = @location.latitude
    @long = @location.longitude
    @dist = 50
    
    # set this to group the results in the view
    Place.distance_grouping_increment = 5
      
    @places = Place.find_near([@lat,@long], :within => @dist)
    
    @map = Cloudkicker::Map.new( :lat      => @lat, 
                                 :long     => @long,
                                 :zoom     => 8,
                                 :style_id => 1714
                                )
    @places.each do |place|
      Cloudkicker::Marker.new( :map   => @map, 
                               :lat   => place.latitude,
                               :long  => place.longitude, 
                               :title => 'Click to display entries for this location.',
                               :info  => render_to_string(:partial => 'entry_marker_tooltip', :locals => {:place => place} )
                             )
    end
  end
  
end