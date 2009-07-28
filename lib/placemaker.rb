class Placemaker
  def initialize(options)
    options.symbolize_keys!
    @application_id = options[:application_id]
  end
  
  def places(text)
    c = Curl::Easy.http_post("http://wherein.yahooapis.com/v1/document",
           Curl::PostField.content('documentContent', text),
           Curl::PostField.content('documentType', 'text/plain'),
           # Curl::PostField.content('autoDisambiguate', 'false'),
           Curl::PostField.content('appid', @application_id)
    )
    
    output = c.body_str
    doc = Nokogiri::XML(output)
    
    places = []
    doc.css('placeDetails').each_with_index do |placedetail_node, i|
      place = Place.new
      place.confidence = placedetail_node.css('confidence').first.content
      placedetail_node.css('place').each do |place_node|
        place.id = place_node.css('woeId').first.content
        place.name = place_node.css('name').first.content
        place.type = place_node.css('type').first.content
        place.latitude = place_node.css('latitude').first.content
        place.longitude = place_node.css('longitude').first.content
      end
      places << place
    end
    
    doc.css('referenceList reference').each do |reference_node|
      woe_ids = reference_node.css('woeIds').first.content.split(' ')
      string = reference_node.css('text').first.content
      
      woe_ids.each do |woe_id|
        places.find{|p| p.id == woe_id}.string = string
      end
    end
    places
  end
  
  class Place
    attr_accessor :id, :name, :type, :confidence, :latitude, :longitude, :string
  end
end