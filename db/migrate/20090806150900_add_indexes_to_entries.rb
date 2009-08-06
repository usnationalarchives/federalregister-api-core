class AddIndexesToEntries < ActiveRecord::Migration
  def self.up
    add_index :entries, :citation
    add_index :entries, :publication_date
  end

  def self.down
    remove_index :entries, :publication_date
    remove_index :entries, :citation
  end
end
