class CreateSections < ActiveRecord::Migration
  def self.up
    create_table :sections do |t|
      t.string :title
      t.string :slug
      t.integer :position
      t.text :description
      t.text :relevant_cfr_sections
      
      t.timestamps
      t.userstamps
    end
    
    create_table :agencies_sections do |t|
      t.integer :section_id
      t.integer :agency_id
      
      t.timestamps
      t.userstamps
    end
    
    add_index :agencies_sections, [:agency_id, :section_id]
    add_index :agencies_sections, [:section_id, :agency_id]
  end

  def self.down
    drop_table :sections
    drop_table :agencies_sections
  end
end
