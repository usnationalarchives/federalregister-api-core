FlickRawOptions = { 'api_key' => ENV['flickr_api_key'] }
require 'flickraw'

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
  
  class Person
    attr_accessor :real_name, :user_name, :location, :profile_url
    
    def initialize(person_id)
      attributes = flickr.people.getInfo(:user_id => person_id)
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