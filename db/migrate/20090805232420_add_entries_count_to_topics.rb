class AddEntriesCountToTopics < ActiveRecord::Migration
  def self.up
    add_column :topics, :entries_count, :integer, :default => 0
    add_index :topics, :entries_count
    
    execute "UPDATE topics SET entries_count = (SELECT count(*) from topic_assignments where topic_id = topics.id)"
  end

  def self.down
    remove_column :topics, :entries_count
  end
end
