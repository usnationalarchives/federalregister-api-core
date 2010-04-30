class CreateAlternativeAgencyNames < ActiveRecord::Migration
  def self.up
    create_table :alternative_agency_names do |t|
      t.integer :agency_id
      t.string :name
    end
    
    add_index :alternative_agency_names, :agency_id
  end

  def self.down
    drop_table :alternative_agency_names
  end
end
