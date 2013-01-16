class FrIndexAgencyStatus < ApplicationModel
  validates_presence_of :year, :agency_id
  validates_uniqueness_of :agency_id, :scope => :year
end