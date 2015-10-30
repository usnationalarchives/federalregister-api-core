class AgencyNameAssignment < ApplicationModel
  validates_presence_of :agency_name

  belongs_to :agency_name
  belongs_to :assignable, :polymorphic => true
  belongs_to :entry, :foreign_key => :assignable_id

  has_one :agency_assignment, :foreign_key => :id, :dependent => :destroy
  has_one :agency, :through => :agency_name
  
  acts_as_list :scope => 'assignable_id = #{assignable_id} AND assignable_type = \'#{assignable_type}\''
end
