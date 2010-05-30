=begin Schema Information

 Table name: agency_assignments

  id        :integer(4)      not null, primary key
  entry_id  :integer(4)
  agency_id :integer(4)
  position  :integer(4)

=end Schema Information

class AgencyAssignment < ApplicationModel
  belongs_to :agency
  belongs_to :assignable, :polymorphic => true
  belongs_to :entry, :foreign_key => :assignable_id
  
  acts_as_list :scope => 'assignable_id = #{assignable_id} AND assignable_type = \'#{assignable_type}\''
end
