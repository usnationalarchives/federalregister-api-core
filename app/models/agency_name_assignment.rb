class AgencyNameAssignment < ApplicationModel
  belongs_to :agency_name
  belongs_to :entry
  
  acts_as_list :scope => :entry_id
  
  after_create :create_agency_assignment
  
  def create_agency_assignment
    if agency_name.agency_id
      AgencyAssignment.create!(:agency_id => agency_name.agency_id, :entry_id => entry_id, :position => position)
    end
  end
end