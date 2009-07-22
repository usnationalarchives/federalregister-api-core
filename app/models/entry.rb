class Entry < ActiveRecord::Base
  has_many :agency_assignments
  has_many :agencies, :through => :agency_assignments
  
  has_many :url_references
  has_many :urls, :through => :url_references
end