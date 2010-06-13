class AddDocketIdToEntries < ActiveRecord::Migration
  def self.up
    add_column :entries, :docket_id, :string
  end

  def self.down
    remove_column :entries, :docket_id, :string
  end
end
