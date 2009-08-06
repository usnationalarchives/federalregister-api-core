class LocationsController < ApplicationController
  
  def index
    @location = Place.find(params[:id])
    @lat   = @location.latitude
    @long  = @location.longitude
    
    @dist = 50
    
    # set this to group the results in the view
    Place.distance_grouping_increment = 5
    
    
    @entries = @location.entries  
    @places = Place.find_near([@lat,@long], :within => @dist, 
                              :include => {:entries => :agency}, 
                              :conditions => ['entries.publication_date > ?', Time.now - 3.years.ago],
                              :order => 'entries.publication_date', 
                              :limit => 50)
    
    if !@places.nil?
      @map = Cloudkicker::Map.new( :style_id   => 1714,
                                   :bounds     => true,
                                   :points     => @places,
                                   :bound_zoom => 7
                                 )
      @places.each do |place|
        Cloudkicker::Marker.new( :map   => @map, 
                                 :lat   => place.latitude,
                                 :long  => place.longitude, 
                                 :title => 'Click to view location info',
                                 :info  => render_to_string(:partial => 'maps/place_marker_tooltip', :locals => {:place => place} ),
                                 :info_max_width => 200
                               )
      end

      @active_agencies = []
      @places.each do |place|
        place.entries.each do |entry|
          if entry.agency
            @active_agencies << entry.agency
          end
        end
      end
      @active_agencies = @active_agencies.sort_by{|a| a.name}.uniq
    end
    
  end
end