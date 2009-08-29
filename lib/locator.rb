module Locator
  require 'geoip'
  
  def current_location(ip = request.remote_ip)
    unless @current_location
      if session[:location]
        @current_location = Geokit::GeoLoc.new session[:location]
      else
        @current_location = Geokit::Geocoders::GeoIp::do_geocode(ip)
        if ! @current_location.success?
          @current_location = default_location
        end
        
        session[:location] = @current_location.to_hash
      end
    end
    
    @current_location
  end
  
  private
  
  def default_location
    Geokit::GeoLoc.new(
      :lng   => -122.073196411133,
      :lat   => 37.3973999023438,
      :city  => "Mountain View",
      :state => "CA"
    )
  end
end