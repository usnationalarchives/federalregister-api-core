class AgencyNameAssignment < ApplicationModel
  validates_presence_of :agency_name

  belongs_to :agency_name
  belongs_to :assignable, :polymorphic => true
  belongs_to :entry, :foreign_key => :assignable_id

  has_one :agency_assignment, :foreign_key => :id, :dependent => :destroy
  acts_as_list :scope => 'assignable_id = #{assignable_id} AND assignable_type = \'#{assignable_type}\''

  after_create :create_agency_assignments

  private

  def create_agency_assignments
    if agency_name.agency
      assignable.agency_assignments << AgencyAssignment.new(
        :agency => agency_name.agency,
        :agency_name_id => agency_name.id
      )
    end
    true
  end
end
