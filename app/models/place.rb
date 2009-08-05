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

class Place < ActiveRecord::Base
  cattr_accessor :distance_grouping, :distance_grouping_increment
  attr_accessor :distance
  
  has_many :place_determinations
  has_many :entries, :through => :place_determinations
  
  acts_as_mappable :lat_column_name => :latitude,
                   :lng_column_name => :longitude
                   
  def location 
    @location = [latitude, longitude]
  end
  
  def find_places_within(dist)
    Place.find_within(dist, :origin => location)
  end
  
  def self.find_near(loc, dist = 100)
    find_within(dist, :origin => loc, :limit => 50)
  end
  
  # use only when you've used geokit to add the distance method as an attr_accessor
  # ie it's added by methods like sort_by_distance_from
  def distance_groups
    cieling = distance.ceil
    dist    = Place.distance_grouping_increment
    num     = Place.distance_grouping_increment
    
    while num <= Place.distance_grouping
      if cieling > num
        dist = num
        num = num + Place.distance_grouping_increment
      else
        dist = num
        break
      end
    end
    
    dist
  end
end
