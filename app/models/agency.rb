class Agency < ActiveRecord::Base
  has_many :agency_assignments
  has_many :entries, :through => :agency_assignments
end