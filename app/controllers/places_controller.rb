class PlacesController < ApplicationController
  def show
    @location = Place.find(params[:id])
    @entries = Entry.all(:conditions => {:place_determinations => {:place_id => @location}}, :joins => :place_determinations, :limit => 50, :order => "publication_date DESC")
    
    respond_to do |wants|
      wants.html do
        @lat   = @location.latitude
        @long  = @location.longitude
  
        @dist = 50
  
        # set this to group the results in the view
        Place.distance_grouping_increment = 5
  
        @places = Place.find_near([@lat,@long], :within => @dist)
  
        local_entries = Entry.find(:all,
          :conditions => {:place_determinations => {:place_id => @places - [@location]}},
          :include => [:place_determinations, :agency],
          :order => "publication_date DESC",
          :limit => 50
        )
  
        @places.each do |place|
          place['recent_entries'] = local_entries.select{|e| e.place_determinations.map{|pd| pd.place_id}.include?(place.id) }
        end
  
        if !@places.nil?
          @map = Cloudkicker::Map.new( :style_id   => 1714,
                                       :bounds     => true,
                                       :points     => [@location],
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
    
    
          [local_entries, @entries].flatten.each do |entry|
            if entry.agency
              @active_agencies << entry.agency
            end
          end
          @active_agencies = @active_agencies.uniq
        end
      end
      
      wants.rss do
        @feed_name = "Federal Register: #{@location.name}"
        @feed_description = "Recent Federal Register entries about #{@location.name}."
        render :template => 'entries/index.rss.builder'
      end
    end
  end
end