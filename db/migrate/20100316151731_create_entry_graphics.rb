class CreateEntryGraphics < ActiveRecord::Migration
  def self.up
    create_table :graphics do |t|
      t.string   :identifier
      t.integer  :usage_count, :default => 0, :null => false
      
      t.string   :graphic_file_name
      t.string   :graphic_content_type
      t.integer  :graphic_file_size
      t.datetime :graphic_updated_at
      
      t.timestamps
    end
    add_index :graphics, :identifier, :unique => true
    
    create_table :graphic_usages do |t|
      t.integer :graphic_id
      t.integer :entry_id
    end
    add_index :graphic_usages, [:entry_id, :graphic_id]
    add_index :graphic_usages, [:graphic_id, :entry_id]
  end
  
  def self.down
    drop_table :graphics
    drop_table :graphic_usages
  end
end
