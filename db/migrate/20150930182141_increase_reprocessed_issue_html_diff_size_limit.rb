class IncreaseReprocessedIssueHtmlDiffSizeLimit < ActiveRecord::Migration
  def self.up
    change_column :reprocessed_issues, :html_diff, :text, :limit => 16777215
  end

  def self.down
    change_column :reprocessed_issues, :html_diff, :text, :limit => nil
  end
end
