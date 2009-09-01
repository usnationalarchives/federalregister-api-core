=begin Schema Information

 Table name: place_determinations

  id         :integer(4)      not null, primary key
  entry_id   :integer(4)
  place_id   :integer(4)
  string     :string(255)
  context    :string(255)
  confidence :integer(4)

=end Schema Information

class PlaceDetermination < ActiveRecord::Base
  MIN_CONFIDENCE = 9
  default_scope :conditions => "place_determinations.confidence >= #{MIN_CONFIDENCE}"
  
  belongs_to :entry
  belongs_to :place
  
  def usable?
   ! Place::UNUSABLE_PLACES.include?(place_id)
  end
end
