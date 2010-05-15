class Flickr
  class Photo
    attr_accessor :id, :title, :owner_id, :farm, :server, :secret
    
    def initialize(attributes)
      @id    = attributes["id"]
      @title = attributes["title"]
      @owner_id = attributes["owner"]
      @farm = attributes["farm"]
      @server = attributes["server"]
      @secret = attributes["secret"]
    end
    
    def owner
      @owner ||= Person.new(owner_id)
    end
    
    def url(size)
      FlickRaw.send("url_#{size}", self)
    end
  end
end