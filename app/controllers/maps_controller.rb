class MapsController < ApplicationController
  include Locator
  include Cloudkicker
  include Geokit::Geocoders
  
  def index
    if params[:location].nil? 
      @location = current_location
      @lat  = @location.latitude
      @long = @location.longitude
      @display_location = "#{@location.city}, #{@location.region}"
    else
      @location = GoogleGeocoder.geocode(params[:location])
      @lat  = @location.lat
      @long = @location.lng
      @display_location = "#{@location.full_address}"
    end
    @dist = 50
    
    # set this to group the results in the view
    Place.distance_grouping_increment = 5
      
    @places = Place.usable.find_near([@lat,@long], :within => @dist, 
                               :limit => 50)
    
    local_entries = Entry.find(:all,
      :conditions => {:place_determinations => {:place_id => @places}},
      :include => [:place_determinations, :agency],
      :order => "publication_date DESC",
      :limit => 50
    )

    @places.each do |place|
      place['recent_entries'] = local_entries.select{|e| e.place_determinations.map{|pd| pd.place_id}.include?(place.id) }
    end

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
    
    @entries = @places.map{|place| place.entries.map{|e| e} }.flatten
    
    @granule_labels = []
    @granule_values = []
    @entries.uniq.group_by(&:granule_class).each do |granule_class, entries|
      @granule_labels << granule_class
      @granule_values << entries.size
    end
    
    @active_agencies = []
    @entries.each do |entry|
      if entry.agency
        @active_agencies << entry.agency
      end
    end
    @active_agencies = @active_agencies.sort_by{|a| a.name}.uniq
  end
  
end