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
end