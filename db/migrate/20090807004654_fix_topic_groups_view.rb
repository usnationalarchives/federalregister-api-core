class FixTopicGroupsView < ActiveRecord::Migration
  def self.up
    execute "ALTER VIEW topic_groups
             AS SELECT group_name, name, SUM(entries_count) AS entries_count
                FROM topics
                WHERE group_name != '' AND group_name IS NOT NULL
                GROUP BY group_name
                ORDER BY LENGTH(name)"
  end

  def self.down
    execute "ALTER VIEW topic_groups
             AS SELECT group_name, name, SUM(entries_count) AS entries_count
                FROM topics
                GROUP BY group_name
                ORDER BY LENGTH(name)"
  end
end
