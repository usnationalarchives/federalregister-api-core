class ResizeEntriesFullTextFields < ActiveRecord::Migration
  def self.up
    change_column :entries, :full_text, :text, :limit => 16777216
    change_column :entries, :full_text_raw, :text, :limit => 16777216
  end

  def self.down
    change_column :entries, :full_text_raw, :text, :limit => 65536
    change_column :entries, :full_text, :text, :limit => 65536
  end
end
