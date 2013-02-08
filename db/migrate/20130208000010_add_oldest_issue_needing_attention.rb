class AddOldestIssueNeedingAttention < ActiveRecord::Migration
  def self.up
    add_column :fr_index_agency_statuses, :oldest_issue_needing_attention, :date
  end

  def self.down
    remove_column :fr_index_agency_statuses, :oldest_issue_needing_attention
  end
end
