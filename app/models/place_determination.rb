class PlaceDetermination < ApplicationModel
  MIN_CONFIDENCE = 9
  MIN_RELEVANCE_SCORE = 0.8

  belongs_to :entry
  belongs_to :place

  def usable?
   ! Place::UNUSABLE_PLACES.include?(place_id)
  end
end
