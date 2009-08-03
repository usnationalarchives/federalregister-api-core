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
    find_within(dist, :origin => loc)
  end
  
  def entry_list
    list = []
    entries.each do |entry|
      list << entry.title
    end
    list.join(', ')
  end
end
