module Locator
  require 'geoip'
  
def current_location(ip = request.remote_ip)
  default_location
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