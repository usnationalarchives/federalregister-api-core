require "geokit"

module Geokit
  module Geocoders
    __define_accessors
    class GeoIp < Geocoder
    
      GEOIP_TO_GEOKIT = {
        :city      => :city,
        :region    => :state,
        :country_code => :country_code,
        :zip       => :zip,
        :latitude  => :lat,
        :longitude => :lng
      }
      
      private
      def self.do_geocode(ip, options = {})
        return GeoLoc.new if '0.0.0.0' == ip
        return GeoLoc.new unless /^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})?$/.match(ip)
        
        begin
          require 'geoip_city'
          
          file_location = options[:file_location] || '/opt/GeoIP/share/GeoIP/GeoLiteCity.dat'
          db = GeoIPCity::Database.new(file_location)
          result = db.look_up(ip)
          if result
            attributes = {}
            GEOIP_TO_GEOKIT.each_pair do |geoip_name, geokit_name|
              attributes[geokit_name] = result[geoip_name]
            end
          
            loc = GeoLoc.new(attributes)
            loc.success = true
            return loc
          else
            return GeoLoc.new
          end
        rescue Exception, LoadError
          logger.error "Caught an error during HostIp geocoding call: "+$!
          return GeoLoc.new
        end
      end
    end
  end
end