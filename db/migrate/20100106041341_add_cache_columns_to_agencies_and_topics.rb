class AddCacheColumnsToAgenciesAndTopics < ActiveRecord::Migration
  def self.up
    add_column :agencies, :related_topics_cache,   :text
    add_column :topics,   :related_topics_cache,   :text
    add_column :topics,   :related_agencies_cache, :text
  end

  def self.down
    remove_column :topics,   :related_agencies_cache
    remove_column :topics,   :related_topics_cache
    remove_column :agencies, :related_topics_cache
  end
end