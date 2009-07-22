class CreateTopics < ActiveRecord::Migration
  def self.up
    create_table :topics do |t|
      t.string  :name
      t.timestamps
    end
    add_index :topics, :name
  end

  def self.down
    drop_table :topics
  end
end
