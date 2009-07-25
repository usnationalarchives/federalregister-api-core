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
  has_many :place_determinations
  has_many :entrys, :through => :place_determinations
end
