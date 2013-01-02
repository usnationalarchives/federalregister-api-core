class AddFrIndexTocColumns < ActiveRecord::Migration
  def self.up
    add_column :entries, :fr_index_subject, :string
    add_column :entries, :fr_index_doc, :string
  end

  def self.down
    remove_column :entries, :fr_index_subject
    remove_column :entries, :fr_index_doc
  end
end
