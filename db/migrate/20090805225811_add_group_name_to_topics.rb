class AddGroupNameToTopics < ActiveRecord::Migration
  def self.up
    add_column :topics, :group_name, :string
    add_index :topics, :group_name
    
    # run callbacks to populate group name
    Topic.all.each {|t| t.save(false) }
  end

  def self.down
    remove_column :topics, :group_name
  end
end
