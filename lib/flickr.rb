require 'flickraw'

FlickRawOptions = { 'api_key' => ENV['flickr_api_key'] }
FlickRaw.api_key = ENV['flickr_api_key']
FlickRaw.shared_secret = ENV['flickr_secret_api_key']

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
   
    def hash
      @id.hash    
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

    def of_appropriate_size?
      large_size_info = raw_sizes.find{|s| s.label == 'Large'}
      if large_size_info
        large_size_info['width'].to_i >= 850
      else
        false
      end
    end

    private

    def raw_sizes
      @raw_sizes ||= flickr.photos.getSizes(:photo_id => id)
    end
  end
  
  class Person
    attr_accessor :real_name, :user_name, :location, :profile_url
    
    def initialize(attributes)
      if attributes.is_a?(String)
        attributes = flickr.people.getInfo(:user_id => attributes)
      end

      @real_name = attributes["realname"]
      @user_name = attributes["username"]
      @location = attributes["location"]
      @profile_url = attributes["profileurl"]
    end
  end
  
  def search(q)
    conditions = {
      :text => q,
      :license => '1,2,4,5,7,8',
      :per_page => 500
    }
    relevant = flickr.photos.search(conditions.merge :sort => 'relevance').map{|attr| Photo.new(attr)}
    interesting = flickr.photos.search(conditions.merge :sort => 'interestingness-desc').map{|attr| Photo.new(attr)}
    
    relevant_and_interesting_ids = relevant.map(&:id) & interesting.map(&:id)
    (relevant.select{|photo| relevant_and_interesting_ids.include?(photo.id)} + relevant).uniq
  end
end
