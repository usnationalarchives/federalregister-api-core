class AddEntriesCountToTopics < ActiveRecord::Migration
  def self.up
    add_column :topics, :entries_count, :integer, :default => 0
    add_index :topics, :entries_count
    
    Topic.reset_column_information
    Topic.find(:all).each do |t|
      Topic.update_counters t.id, :entries_count => t.entries.length
    end
  end

  def self.down
    remove_column :topics, :entries_count
  end
end
