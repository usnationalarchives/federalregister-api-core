class RemoveTopicGroups < ActiveRecord::Migration
  def self.up
    execute "DROP VIEW topic_groups"
    rename_column :topics, :group_name, :slug
    Topic.all.each {|t| t.save }
  end

  def self.down
    rename_column :topics, :slug, :group_name
    execute "CREATE VIEW topic_groups
             AS SELECT group_name, name, SUM(entries_count) AS entries_count, related_topics_cache, related_agencies_cache
                FROM topics
                GROUP BY group_name
                ORDER BY LENGTH(name)"
  end
end
