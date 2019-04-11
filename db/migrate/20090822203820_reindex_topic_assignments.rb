class ReindexTopicAssignments < ActiveRecord::Migration
  def self.up
    add_index :topic_assignments, [:entry_id, :topic_id]
    add_index :topic_assignments, [:topic_id, :entry_id]
    remove_index :topic_assignments, :entry_id
    remove_index :topic_assignments, :topic_id
  end

  def self.down
    add_index :topic_assignments, :topic_id
    add_index :topic_assignments, :entry_id
    remove_index :topic_assignments, [:topic_id, :entry_id]
    remove_index :topic_assignments, [:entry_id, :topic_id]
  end
end
