class CreateSectionAssignments < ActiveRecord::Migration
  def self.up
    create_table :section_assignments do |t|
      t.integer :entry_id
      t.integer :section_id
    end
    
    add_index :section_assignments, [:section_id, :entry_id]
  end

  def self.down
    drop_table :section_assignments
  end
end
