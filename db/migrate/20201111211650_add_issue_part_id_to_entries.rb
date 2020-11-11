class AddIssuePartIdToEntries < ActiveRecord::Migration[6.0]
  def change
    change_table :entries do |t|
      t.integer :issue_part_id
    end
    add_index :entries, :issue_part_id
  end
end
