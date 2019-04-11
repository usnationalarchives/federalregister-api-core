class AddIndexToEntriesForPrevNext < ActiveRecord::Migration
  def self.up
    remove_index :entries, [:volume, :start_page, :end_page]
    add_index :entries,    [:volume, :start_page, :id]
  end

  def self.down
    remove_index :entries, [:volume, :start_page, :id]
    add_index :entries, [:volume, :start_page, :end_page]
  end
end
