class CreateIssueApprovals < ActiveRecord::Migration
  def self.up
    create_table :issue_approvals do |t|
      t.date :publication_date
      t.userstamps
      t.timestamps
    end
    add_index :issue_approvals, :publication_date
  end

  def self.down
    drop_table :issue_approvals
  end
end
