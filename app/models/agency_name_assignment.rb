=begin Schema Information

 Table name: agency_name_assignments

  id              :integer(4)      not null, primary key
  assignable_id   :integer(4)
  agency_name_id  :integer(4)
  position        :integer(4)
  assignable_type :string(255)

=end Schema Information

class AgencyNameAssignment < ApplicationModel
  belongs_to :agency_name
  belongs_to :assignable, :polymorphic => true
  
  acts_as_list :scope => 'assignable_id = #{assignable_id} AND assignable_type = \'#{assignable_type}\''
  
  after_create :create_agency_assignment
  
  def create_agency_assignment
    if agency_name.agency_id
      AgencyAssignment.create!(:agency_id => agency_name.agency_id, :assignable => assignable, :position => position)
    end
  end
end
