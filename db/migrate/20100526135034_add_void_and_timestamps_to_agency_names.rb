class AddVoidAndTimestampsToAgencyNames < ActiveRecord::Migration
  def self.up
    add_column :agency_names, :void, :boolean, :default => false
    add_column :agency_names, :created_at, :datetime
    add_column :agency_names, :updated_at, :datetime
    remove_column :agency_names, :agency_assigned
  end

  def self.down
    add_column :agency_names, :agency_assigned, :boolean
    remove_column :agency_names, :void
    remove_column :agency_names, :created_at
    remove_column :agency_names, :updated_at
  end
end
