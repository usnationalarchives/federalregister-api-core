class CreateTopicNames < ActiveRecord::Migration
  def self.up
    create_table :topic_names do |t|
      t.string :name
      t.boolean :void, :default => false
      t.integer :entries_count, :default => 0
      t.integer :topics_count, :default => 0
      
      t.timestamps
    end
    add_index :topic_names, :name
    add_index :topic_names, [:void, :topics_count]
    
    create_table :topic_name_assignments do |t|
      t.integer :entry_id
      t.integer :topic_name_id
    
      t.timestamps
    end
    add_index :topic_name_assignments, [:entry_id, :topic_name_id]
    add_index :topic_name_assignments, [:topic_name_id, :entry_id]
    
    create_table :topics_topic_names do |t|
      t.integer :topic_id
      t.integer :topic_name_id
      
      t.timestamps
      t.userstamps
    end
    add_index :topics_topic_names, [:topic_id, :topic_name_id]
    add_index :topics_topic_names, [:topic_name_id, :topic_id]
    
    execute("INSERT INTO topic_names (id, name, entries_count, created_at, updated_at) SELECT id, name, entries_count, created_at, updated_at FROM topics")
    execute("INSERT INTO topic_name_assignments (entry_id, topic_name_id, created_at, updated_at) SELECT entry_id, topic_id, created_at, updated_at FROM topic_assignments")
    Content::TopicImporter.new.perform
  end

  def self.down
    drop_table :topics_topic_names
    drop_table :topic_name_assignments
    drop_table :topic_names
  end
end
