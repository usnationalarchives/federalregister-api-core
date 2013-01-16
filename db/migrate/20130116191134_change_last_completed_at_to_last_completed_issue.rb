class ChangeLastCompletedAtToLastCompletedIssue < ActiveRecord::Migration
  def self.up
    rename_column :fr_index_agency_statuses, :last_completed_at, :last_completed_issue
    change_column :fr_index_agency_statuses, :last_completed_issue, :date
  end

  def self.down
    change_column :fr_index_agency_statuses, :last_completed_issue, :datetime
    rename_column :fr_index_agency_statuses, :last_completed_issue, :last_completed_at
  end
end
