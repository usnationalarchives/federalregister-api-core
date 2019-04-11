class AddMulticolumnIndexToEntries < ActiveRecord::Migration
  def self.up
    add_index :entries, [:agency_id, :publication_date]
    add_index :entries, [:publication_date, :agency_id]
    remove_index :entries, :agency_id
    remove_index :entries, :publication_date
  end

  def self.down
    add_index :entries, :publication_date
    add_index :entries, :agency_id
    remove_index :entries, [:agency_id, :publication_date]
    remove_index :entries, [:publication_date, :agency_id]
  end
end
