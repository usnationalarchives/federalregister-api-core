class ReindexTopics < ActiveRecord::Migration
  def self.up
    add_index :topics, [:group_name, :id]
    remove_index :topics, :group_name
  end

  def self.down
    add_index :topics, :group_name
    remove_index :topics, [:group_name, :id]
  end
end
