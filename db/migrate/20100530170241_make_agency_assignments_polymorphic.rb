class MakeAgencyAssignmentsPolymorphic < ActiveRecord::Migration
  def self.up
    remove_index :agency_assignments, [:entry_id, :agency_id]
    add_column :agency_assignments, :assignable_type, :string
    execute "UPDATE agency_assignments SET assignable_type = 'Entry'"
    rename_column :agency_assignments, :entry_id, :assignable_id
    
    add_index :agency_assignments, [:assignable_type, :assignable_id, :agency_id], :name => 'index_agency_assignments_on_assignable_and_agency_id'
    
    remove_index :agency_name_assignments, [:entry_id, :agency_name_id]
    add_column :agency_name_assignments, :assignable_type, :string
    execute "UPDATE agency_name_assignments SET assignable_type = 'Entry'"
    rename_column :agency_name_assignments, :entry_id, :assignable_id
    
    add_index :agency_name_assignments, [:assignable_type, :assignable_id, :agency_name_id], :name => 'index_agency_name_assignments_on_assignable_and_agency_name_id'
  end

  def self.down
    remove_index :agency_name_assignments, :name => 'index_agency_name_assignments_on_assignable_and_agency_name_id'
    rename_column :agency_name_assignments, :assignable_id, :entry_id
    remove_column :agency_name_assignments, :assignable_type
    add_index :agency_name_assignments, [:entry_id, :agency_name_id]
    
    remove_index :agency_assignments, :name => 'index_agency_assignments_on_assignable_and_agency_id'
    
    rename_column :agency_assignments, :assignable_id, :entry_id
    remove_column :agency_assignments, :assignable_type
    add_index :agency_assignments, [:entry_id, :agency_id]
  end
end
