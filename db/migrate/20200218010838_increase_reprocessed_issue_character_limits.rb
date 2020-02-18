class IncreaseReprocessedIssueCharacterLimits < ActiveRecord::Migration[6.0]
  def change
    change_column :reprocessed_issues, :status, :string, limit: 1000
    change_column :reprocessed_issues, :message, :string, limit: 1000

    add_index :reprocessed_issues, [:issue_id, :status]
  end
end
