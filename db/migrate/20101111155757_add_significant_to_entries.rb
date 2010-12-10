class AddSignificantToEntries < ActiveRecord::Migration
  def self.up
    add_column :entries, :significant, :boolean, :default => false
    add_index :entries, :significant
  end

  def self.down
    remove_column :entries, :significant
  end
end
