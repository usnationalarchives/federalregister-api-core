class PlaceDetermination < ApplicationModel
  MIN_CONFIDENCE = 9
  default_scope :conditions => "place_determinations.confidence >= #{MIN_CONFIDENCE}"
  named_scope :all_confidences, with_exclusive_scope { find(:all) }

  belongs_to :entry
  belongs_to :place

  def usable?
   ! Place::UNUSABLE_PLACES.include?(place_id)
  end
end
