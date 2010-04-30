class AlternativeAgencyName < ActiveRecord::Base
  validates_presence_of :agency, :name
  belongs_to :agency
end