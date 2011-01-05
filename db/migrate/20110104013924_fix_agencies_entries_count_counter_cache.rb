class FixAgenciesEntriesCountCounterCache < ActiveRecord::Migration
  def self.up
    # not all agencies have entries, so wouldn't be matched by the query that does the real calculation
    execute "UPDATE agencies SET entries_count = 0"
    execute "UPDATE agencies,
                (
                 SELECT agency_id, COUNT(DISTINCT(assignable_id)) AS entries_count
                 FROM agency_assignments
                 WHERE agency_assignments.assignable_type = 'Entry'
                 GROUP BY agency_assignments.agency_id
                ) AS agency_assignment_counts
             SET agencies.entries_count = agency_assignment_counts.entries_count
             WHERE agencies.id = agency_assignment_counts.agency_id"
    change_column :agencies, :entries_count, :integer, :default => 0,  :null => false
  end

  def self.down
    change_column :agencies, :entries_count, :integer, :default => nil,  :null => true
  end
end
