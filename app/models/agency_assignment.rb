class AgencyAssignment < ActiveRecord::Base
  belongs_to :agency
  belongs_to :entry
end