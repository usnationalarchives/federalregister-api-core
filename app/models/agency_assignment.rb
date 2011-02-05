=begin Schema Information

 Table name: agency_assignments

  id              :integer(4)      not null, primary key
  assignable_id   :integer(4)
  agency_id       :integer(4)
  position        :integer(4)
  assignable_type :string(255)
  agency_name_id  :integer(4)

=end Schema Information

class AgencyAssignment < ApplicationModel
  belongs_to :agency
  belongs_to :assignable, :polymorphic => true
  belongs_to :entry, :foreign_key => :assignable_id
  belongs_to :agency_name
  
  after_create :increment_entry_counter_cache
  after_destroy :decrement_entry_counter_cache
  
  acts_as_list :scope => 'assignable_id = #{assignable_id} AND assignable_type = \'#{assignable_type}\''
  
  def self.recalculate!
    connection.execute("TRUNCATE agency_assignments")
    connection.execute("INSERT INTO agency_assignments (id, assignable_id, assignable_type, position, agency_id)
      SELECT agency_name_assignments.id, agency_name_assignments.assignable_id, agency_name_assignments.assignable_type, agency_name_assignments.position, agency_names.agency_id
      FROM agency_name_assignments
      JOIN agency_names ON agency_names.id = agency_name_assignments.agency_name_id
      WHERE agency_names.agency_id IS NOT NULL")
  end
  
  private
  
  def increment_entry_counter_cache
    Agency.increment_counter(:entries_count, agency_id) if assignable_type == 'Entry'
    true
  end
  
  def decrement_entry_counter_cache
    Agency.decrement_counter(:entries_count, agency_id) if assignable_type == 'Entry'
    true
  end
  
end
