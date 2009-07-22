class CreateAgencyAssignments < ActiveRecord::Migration
  def self.up
    create_table :agency_assignments do |t|
      t.belongs_to :agency
      t.belongs_to :entry
      t.timestamps
    end
    add_index :agency_assignments, :agency_id
    add_index :agency_assignments, :entry_id
  end

  def self.down
    drop_table :agency_assignments
  end
end
