class AddSlugToEntriesAndAgencies < ActiveRecord::Migration
  def self.up
    add_column :agencies, :slug, :string
    add_column :entries, :slug, :text
  end

  def self.down
    remove_column :entries, :slug
    remove_column :agencies, :slug
  end
end
