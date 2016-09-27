class AddMissingTimestampColumns < ActiveRecord::Migration
  def self.up
    add_column :dockets, :created_at, :datetime
    add_column :dockets, :updated_at, :datetime

    add_column :fr_index_agency_statuses, :created_at, :datetime
    add_column :fr_index_agency_statuses, :updated_at, :datetime
  end

  def self.down
  end
end
