class AddIndexToGpoGraphics < ActiveRecord::Migration
  def self.up
    add_index :gpo_graphics, :graphic_file_name
  end

  def self.down
    remove_index :gpo_graphics, :graphic_file_name
  end
end
