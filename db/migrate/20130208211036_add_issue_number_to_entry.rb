class AddIssueNumberToEntry < ActiveRecord::Migration
  def self.up
    add_column :entries, :issue_number, :integer
  end

  def self.down
    remove_column :entries, :issue_number
  end
end
