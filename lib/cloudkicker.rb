module Cloudkicker
  class Map
    def initialize(options={})
      @lat          = options.delete(:lat)         || 37.778605
      @long         = options.delete(:long)        || -122.391369
      @map_control  = options.delete(:map_control) || true
      @zoom         = options.delete(:zoom)        || 10
      @style_id     = options.delete(:style_id)    || 2
      @bounds       = options.delete(:bounds)      || false
      @bound_points = options.delete(:points)      || 0
      @bound_zoom   = options.delete(:bound_zoom)  || 2 #used when only a single point is passed to bound_points
      @markers      = []
    end
    
    def to_js(map_id='map')
      js = []
      js << "<script type=\"text/javascript\" src=\"#{CLOUDMADE_SRC}\"></script>"
      
      js << '<script type="text/javascript">'
      js << '$(document).ready(function() {'
      
      js << "   var cloudmade = new CM.Tiles.CloudMade.Web({key: '#{CLOUDMADE_API_KEY}', styleId: #{@style_id}});"
      js << "   var map = new CM.Map('#{map_id}', cloudmade);"
      # TODO: disable mouse zoom should be an option in an map options class
      js << "   map.disableScrollWheelZoom();"
      
      if @bounds 
        if @bound_points.size > 1
          js << "   map.zoomToBounds(#{bounding_box(@bound_points)})"
        elsif @bound_points.size == 1
          js << "   map.setCenter(new CM.LatLng(#{@bound_points.first.latitude}, #{@bound_points.first.longitude}), #{@bound_zoom});"
        else
          raise "You must provide at least one point (via :bound_points) if you are using :bounds => true"
        end
      else
        js << "   map.setCenter(new CM.LatLng(#{@lat}, #{@long}), #{@zoom});"
      end
      if @map_control
        js << '   var topRight = new CM.ControlPosition(CM.TOP_RIGHT, new CM.Size(10, 10));'
        js << '   map.addControl(new CM.LargeMapControl(), topRight);'
      end
      
      @markers.each do |marker|
        js << marker
      end
      
      js << '});'
      js << '</script>'
      js.join("\n")
    end
  
    def markers
      @markers
    end
    
    def bounding_box(points)
      # lats  = []
      # longs = []
      # points.each do |point|
      #   lats  << point.latitude
      #   longs << point.longitude
      # end
      # 
      # max_lat = lats.max
      # min_lat = lats.min
      # max_long = longs.max
      # min_long = longs.min
      # 
      # north_east_lat  = max_lat  + (max_lat  - min_lat)
      # north_east_long = max_long + (max_long - min_long)
      # 
      # south_west_lat  = min_lat  - (max_lat  - min_lat)
      # south_west_long = min_long - (max_long - min_long)
      
      cloud_map_points = []
    
      points.each do |point|
        cloud_map_points << "new CM.LatLng(#{point.latitude}, #{point.longitude})"
      end
      
      "new CM.LatLngBounds(#{cloud_map_points.join(',')})"
    end
  end
  
  class Marker
    def initialize(options={})
      raise 'Map is required'  unless options[:map]
      raise 'Lat is required'  unless options[:lat]
      raise 'Long is required' unless options[:long]
      @map   = options.delete(:map)
      @lat   = options.delete(:lat)
      @long  = options.delete(:long)
      @id    = self.object_id
      @title = options.delete(:title) || ''
      @info  = options.delete(:info)  || ''
      @max_width = options.delete(:info_max_width) || 400
      add_marker
    end
    
    private
    
    def add_marker
      js = []
      js << "   var myMarkerLatLng_#{@id} = new CM.LatLng(#{@lat},#{@long});"
      
      js << '   var icon = new CM.Icon();'
      js << '   icon.image  = "/images/map_marker.png";'
      js << '   icon.iconSize = new CM.Size(31, 48);'
      js << '   icon.shadow  = "/images/map_marker_shadow.png";'
      js << '   icon.shadowSize = new CM.Size(31, 48);'
      js << '   icon.iconAnchor = new CM.Point(20, 48);'
      
      js << "   var myMarker_#{@id} = new CM.Marker(myMarkerLatLng_#{@id}, {"
      js << "     title: '#{@title}',"
      js << "     icon: icon"
      js << '   });'
      
      # Add listener to marker
      js << "   CM.Event.addListener(myMarker_#{@id}, 'click', function(latlng) {"
      # TODO single quotes should be esacaped not deleted. Escaping doesn't seem to be working at the moment though... clearly missing something
      js << "     map.openInfoWindow(myMarkerLatLng_#{@id}, '#{@info.gsub(/'/,"")}', {maxWidth: #{@max_width}, pixelOffset: new CM.Size(-8,-50)});"
      js << '   });'
      
      js << ''
      # js << '   map.setCenter(myMarkerLatLng, 14);'
      js << "   map.addOverlay(myMarker_#{@id});"
      @map.markers << js.join("\n")
    end
  end
end