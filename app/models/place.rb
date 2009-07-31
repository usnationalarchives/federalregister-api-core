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
  has_many :entrys, :through => :place_determinations
  
  acts_as_mappable :lat_column_name => :latitude,
                   :lng_column_name => :longitude
                   
  def location 
    @location = [latitude, longitude]
  end
  
  def find_places_within(dist)
    Place.find(:all, :origin => location, :within => dist)
  end
  
  # def find_entries_within(dist)
  #   places = find_places_within(dist)
  #   entries = []
  #   places.each do |place|
  #     entries << place.entry
  #   end
  # end
end
