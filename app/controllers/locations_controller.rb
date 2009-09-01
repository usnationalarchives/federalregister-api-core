class LocationsController < ApplicationController
  def edit
    @location = current_location
  end
  
  def update
    @location = Geokit::Geocoders::GoogleGeocoder.geocode(params[:geokit_geo_loc][:name])
    
    if @location.success
      session[:location] = @location.to_hash
      redirect_to params[:redirect_to] || root_url
    else
      @message = 'We could not understand that location.'
      @location = current_location
      render :action => 'edit'
    end
  end
  
  def congress
    members_of_congress = Sunlight::Legislator.all_for(:latitude => current_location.lat, :longitude => current_location.lng)
    @senators = members_of_congress.values_at(:senior_senator, :junior_senator)
    @reps     = members_of_congress.values_at(:representative)
    
    render :layout => false
  end
end