FlickRawOptions = { 'api_key' => ENV['flickr_api_key'] }
require 'flickraw'

class Flickr
  class Photo
    attr_accessor :id, :title, :owner, :farm, :server, :secret
    
    def initialize(attributes)
      @id    = attributes["id"]
      @title = attributes["title"]
      @owner = attributes["owner"]
      @farm = attributes["farm"]
      @server = attributes["server"]
      @secret = attributes["secret"]
    end
    
    def creator
      @creator ||= Person.new(owner)
    end
    
    def url(size)
      FlickRaw.send("url_#{size}", self)
    end
    
    def self.find_by_id(id)
      Photo.new(flickr.photos.getInfo(:photo_id => id))
    end
  end
  
  class Person
    attr_accessor :real_name, :user_name, :location, :profile_url
    
    def initialize(attributes)
      @real_name = attributes["realname"]
      @user_name = attributes["username"]
      @location = attributes["location"]
      @profile_url = attributes["profileurl"]
    end
  end
  
  def initialize
    FlickRaw.api_key=ENV['flickr_api_key']
    FlickRaw.shared_secret=ENV['flickr_secret_api_key']
  end
  
  def search(q)
    flickr.photos.search(
      :text => q,
      :license => '1,2,4,5,7,8',
      :per_page => 25,
      :sort => 'interestingness-desc'
    ).map do |attributes|
      Photo.new(attributes)
    end
  end
end