class AgencyAssignment < ApplicationModel
  belongs_to :agency
  belongs_to :entry
  
  acts_as_list :scope => :entry_id
end