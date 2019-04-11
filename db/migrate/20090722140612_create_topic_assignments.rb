class CreateTopicAssignments < ActiveRecord::Migration
  def self.up
    create_table :topic_assignments do |t|
      t.belongs_to :topic
      t.belongs_to :entry
      t.timestamps
    end
    add_index :topic_assignments, :topic_id
    add_index :topic_assignments, :entry_id
  end

  def self.down
    drop_table :topic_assignments
  end
end
