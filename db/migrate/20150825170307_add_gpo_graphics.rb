class AddGpoGraphics < ActiveRecord::Migration
  def self.up
    create_table :gpo_graphics do |t|
      t.string   :identifier

      #Attributes used by Paperclip
      t.string   :graphic_file_name
      t.string   :graphic_content_type
      t.integer  :graphic_file_size
      t.datetime :graphic_updated_at

      t.timestamps
    end
    add_index :gpo_graphics, :identifier, :unique => true

  end

  def self.down
    drop_table :gpo_graphics
  end
end
