class OverhaulAgencyAssignmentProcess < ActiveRecord::Migration
  def self.up
    create_table :agency_names do |t|
      t.string :name, :null => false
      t.boolean :agency_assigned
      t.integer :agency_id
    end
    add_index :agency_names, [:agency_id, :name]
    add_index :agency_names, [:name, :agency_id]
    add_index :agency_names, :name, :unique => true
    
    create_table :agency_name_assignments do |t|
      t.integer :entry_id
      t.integer :agency_name_id
      t.integer :position
    end
    add_index :agency_name_assignments, [:entry_id, :agency_name_id]
    add_index :agency_name_assignments, [:agency_name_id, :entry_id]
    
    create_table :agency_assignments do |t|
      t.integer :entry_id
      t.integer :agency_id
      t.integer :position
    end
    add_index :agency_assignments, [:entry_id, :agency_id]
    add_index :agency_assignments, [:agency_id, :entry_id]
    
    drop_table :alternative_agency_names
    
    remove_column :entries, :agency_id
    remove_column :entries, :primary_agency_raw
    remove_column :entries, :secondary_agency_raw
  end

  def self.down
    add_column :entries, :secondary_agency_raw, :string
    add_column :entries, :primary_agency_raw, :string
    add_column :entries, :entry_id, :integer
    
    create_table :alternative_agency_names do |t|
      t.integer :agency_id
      t.string :name
    end
    add_index :alternative_agency_names, :agency_id
    
    drop_table :agency_assignments
    
    drop_table :agency_name_assignments
    
    drop_table :agency_names
  end
end
