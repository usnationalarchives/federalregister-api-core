=begin Schema Information

 Table name: agency_name_assignments

  id             :integer(4)      not null, primary key
  entry_id       :integer(4)
  agency_name_id :integer(4)
  position       :integer(4)

=end Schema Information

class AgencyNameAssignment < ApplicationModel
  belongs_to :agency_name
  belongs_to :entry
  
  acts_as_list :scope => :entry_id
  
  after_create :create_agency_assignment
  
  private
    
    def create_agency_assignment
      if agency_name.agency_id
        AgencyAssignment.create!(:agency_id => agency_name.agency_id, :entry_id => entry_id, :position => position)
      end
    end
end
