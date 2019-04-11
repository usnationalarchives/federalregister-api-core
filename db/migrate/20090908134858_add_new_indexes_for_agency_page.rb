class AddNewIndexesForAgencyPage < ActiveRecord::Migration
  def self.up
    add_index :entries, [:agency_id, :id]
    add_index :entries, [:agency_id, :granule_class]
  end

  def self.down
    remove_index :entries, [:agency_id, :granule_class]
    remove_index :entries, [:agency_id, :id]
  end
end
