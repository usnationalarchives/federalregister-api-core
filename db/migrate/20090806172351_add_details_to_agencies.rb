class AddDetailsToAgencies < ActiveRecord::Migration
  def self.up
    add_column :agencies, :agency_type, :string
    add_column :agencies, :short_name, :string
    add_column :agencies, :description, :text
    add_column :agencies, :more_information, :text
  end

  def self.down
    remove_column :agencies, :more_information
    remove_column :agencies, :description
    remove_column :agencies, :short_name
    remove_column :agencies, :agency_type
  end
end
