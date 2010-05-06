=begin Schema Information

 Table name: places

  id         :integer(4)      not null, primary key
  name       :string(255)
  place_type :string(255)
  latitude   :float
  longitude  :float
  created_at :datetime
  updated_at :datetime

=end Schema Information

class Place < ApplicationModel
  UNUSABLE_PLACES = [23424977,2393620]
  
  cattr_accessor :distance_grouping_increment
  attr_accessor :distance
  
  has_many :place_determinations, :conditions => "place_determinations.confidence >= #{PlaceDetermination::MIN_CONFIDENCE}"
  has_many :entries, :through => :place_determinations
  
  named_scope :usable, :conditions => ['places.id NOT IN (?)', UNUSABLE_PLACES]
  
  acts_as_mappable :lat_column_name => :latitude,
                   :lng_column_name => :longitude

  def slug
    "#{self.name.downcase.gsub(/&/, 'and').gsub(/[^a-z0-9]+/, '-')}"
  end
  
  def usable?
    ! UNUSABLE_PLACES.include?(id)
  end
  
  def location 
    @location = [latitude, longitude]
  end
  
  def find_places_within(dist)
    Place.find_within(dist, :origin => location)
  end
  
  def self.find_near(origin, options={})
    options.symbolize_keys!
    defaults = {
      :within => 100,
      :limit => 50
    }
    opts = defaults.merge(options.slice(:within,:limit,:include,:order,:conditions)).merge({:origin => origin})
    
    find(:all, opts)
  end
  
  # use only when you've used geokit to add the distance method as an attr_accessor
  # ie it's added by methods like sort_by_distance_from
  def distance_groups
    num = Place.distance_grouping_increment
    dist = ( (distance / num).to_i + 1) * num
    dist
  end
end
