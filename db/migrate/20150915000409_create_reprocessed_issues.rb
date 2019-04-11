class CreateReprocessedIssues < ActiveRecord::Migration
  def self.up
    create_table :reprocessed_issues do |t|
      t.integer :issue_id
      t.string :status
      t.string :message
      t.text :diff
      t.integer :user_id
      t.timestamps
    end
    add_index :reprocessed_issues, [:issue_id, :status]
    add_index :reprocessed_issues, :user_id
  end

  def self.down
    drop_table :reprocessed_issues
  end
end
