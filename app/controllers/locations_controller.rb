class LocationsController < ApplicationController
  def edit
    @location = current_location
  end
  
  def places
    @dist = 20
    @location = current_location
    @lat  = @location.lat
    @long = @location.lng
    @places = Place.usable.find_near([@lat,@long], :within => @dist, :limit => 20)
    
    @map = Cloudkicker::Map.new( :style_id => 1714,
                                 :zoom     => 8,
                                 :lat      => @places.map(&:latitude).average,
                                 :long     => @places.map(&:longitude).average
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
    render :layout => 'minimal'
  end
  
  def update
    @location = Geokit::Geocoders::GoogleGeocoder.geocode(params[:geokit_geo_loc][:name])
    
    if @location.success
      session[:location] = @location.to_hash
      if params[:redirect_to].present?
        redirect_to params[:redirect_to]
      else 
        redirect_to root_url
      end
    else
      @message = 'We could not understand that location.'
      @location = current_location
      render :action => 'edit'
    end
  end
end