class AddUrlToAgencies < ActiveRecord::Migration
  def self.up
    add_column :agencies, :url, :string
  end

  def self.down
    remove_column :agencies, :url, :string
  end
end
