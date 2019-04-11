class AddCfrInfoToEntries < ActiveRecord::Migration
  def self.up
    add_column :entries, :cfr_title, :string
    add_column :entries, :cfr_part,  :string
  end

  def self.down
    remove_column :entries, :cfr_title, :string
    remove_column :entries, :cfr_part,  :string
  end
end
