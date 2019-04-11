class FixColumnNamesInEntries < ActiveRecord::Migration
  def self.up
    rename_column :entries, :full_text_added_at, :full_text_updated_at
    rename_column :entries, :full_xml_added_at, :full_xml_updated_at
  end

  def self.down
    rename_column :entries, :full_text_updated_at, :full_text_added_at
    rename_column :entries, :full_xml_updated_at, :full_xml_added_at
  end
end
