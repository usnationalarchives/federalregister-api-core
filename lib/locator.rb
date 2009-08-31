module Locator
  def remote_location(ip = request.remote_ip)
    begin
      require 'ostruct'
      require 'geoip_city'
      
      db = GeoIPCity::Database.new('/opt/GeoIP/share/GeoIP/GeoLiteCity.dat')
      
      result = db.look_up(ip)
      
      if result
        OpenStruct.new(result)
      else
        OpenStruct.new({
          :longitude=>-122.073196411133,
          :country_code3=>"USA",
          :country_name=>"United States",
          :area_code=>650,
          :city=>"Mountain View",
          :region=>"CA",
          :latitude=>37.3973999023438,
          :country_code=>"US",
          :dma_code=>807
        })
      end
    rescue MissingSourceFile => e
      OpenStruct.new({
        :longitude=>-122.073196411133,
        :country_code3=>"USA",
        :country_name=>"United States",
        :area_code=>650,
        :city=>"Mountain View",
        :region=>"CA",
        :latitude=>37.3973999023438,
        :country_code=>"US",
        :dma_code=>807
      })
    rescue Errno::ENOENT => e
      OpenStruct.new({
        :longitude=>-122.073196411133,
        :country_code3=>"USA",
        :country_name=>"United States",
        :area_code=>650,
        :city=>"Mountain View",
        :region=>"CA",
        :latitude=>37.3973999023438,
        :country_code=>"US",
        :dma_code=>807
      })
    end
  end
end