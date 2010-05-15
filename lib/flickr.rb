FlickRawOptions = { 'api_key' => ENV['flickr_api_key'] }
require 'flickraw'

class Flickr
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
require Flickr::Person
require Flickr::Photo
