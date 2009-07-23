class Place < ActiveRecord::Base
  has_many :place_determinations
  has_many :entrys, :through => :place_determinations
end