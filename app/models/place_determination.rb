class PlaceDetermination < ApplicationModel
  MIN_CONFIDENCE = 9

  belongs_to :entry
  belongs_to :place

  def usable?
   ! Place::UNUSABLE_PLACES.include?(place_id)
  end
end
