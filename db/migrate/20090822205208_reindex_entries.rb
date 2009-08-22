class ReindexEntries < ActiveRecord::Migration
  def self.up
    add_index :entries, [:id, :publication_date]
  end

  def self.down
    remove_index :entries, [:id, :publication_date]
  end
end
