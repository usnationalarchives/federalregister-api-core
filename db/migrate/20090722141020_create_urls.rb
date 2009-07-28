class CreateUrls < ActiveRecord::Migration
  def self.up
    create_table :urls do |t|
      t.string  :name, :type, :content_type
      t.integer :response_code
      t.float :content_length
      t.string :title
      
      t.timestamps
    end
    add_index :urls, :name
    add_index :urls, :type
  end

  def self.down
    drop_table :urls
  end
end
