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
    if current_location.is_us?
      members_of_congress = Rails.cache.fetch("legislators_for #{current_location.lat}, #{current_location.lng}") do
        Sunlight::Legislator.all_for(:latitude => current_location.lat, :longitude => current_location.lng)
      end
      
      @senators = members_of_congress.values_at(:senior_senator, :junior_senator).reject &:nil?
      @reps     = members_of_congress.values_at(:representative).reject &:nil?
      
      render :layout => false
    else
      render :text => ''
    end
  end
end