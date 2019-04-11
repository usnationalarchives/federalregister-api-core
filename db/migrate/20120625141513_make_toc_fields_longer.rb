class MakeTocFieldsLonger < ActiveRecord::Migration
  def self.up
    change_column :entries, :toc_subject, :string, :limit => 1000
    change_column :entries, :toc_doc, :string, :limit => 1000
  end

  def self.down
    change_column :entries, :toc_subject, :string, :limit => 255
    change_column :entries, :toc_doc, :string, :limit => 255
  end
end
