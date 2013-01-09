class RemoveUnusedFieldsFromEntries < ActiveRecord::Migration
  def self.up
    remove_column :entries, :type, :link, :genre, :length, :slug
  end

  def self.down
    add_column :entries, :type, :string
    add_column :entries, :link, :string
    add_column :entries, :genre, :string
    add_column :entries, :length, :string
    add_column :entries, :slug, :string
  end
end
