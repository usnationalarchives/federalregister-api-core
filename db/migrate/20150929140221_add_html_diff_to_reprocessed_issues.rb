class AddHtmlDiffToReprocessedIssues < ActiveRecord::Migration
  def self.up
    add_column :reprocessed_issues, :html_diff, :text
  end

  def self.down
    remove_column :reprocessed_issues, :html_diff
  end
end
