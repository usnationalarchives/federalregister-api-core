class UpdateTopicGroupsView < ActiveRecord::Migration
  def self.up
    execute "DROP VIEW topic_groups"
    execute "CREATE VIEW topic_groups
             AS SELECT group_name, name, SUM(entries_count) AS entries_count, related_topics_cache, related_agencies_cache
                FROM topics
                GROUP BY group_name
                ORDER BY LENGTH(name)"
  end

  def self.down
    execute "DROP VIEW topic_groups"
    execute "CREATE VIEW topic_groups
             AS SELECT group_name, name, SUM(entries_count) AS entries_count
                FROM topics
                GROUP BY group_name
                ORDER BY LENGTH(name)"
  end
end
