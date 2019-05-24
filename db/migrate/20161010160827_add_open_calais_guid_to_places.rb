class AddOpenCalaisGuidToPlaces < ActiveRecord::Migration
  def self.up
    add_column :places, :open_calais_guid, :string, :limit => 100
    add_index :places, :open_calais_guid, :unique => true
  end

  def self.down
    remove_index :places, :open_calais_guid
    remove_column :places, :open_calais_guid
  end
end
