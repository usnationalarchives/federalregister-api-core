class AddInvertedToGraphics < ActiveRecord::Migration
  def self.up
    add_column :graphics, :inverted, :boolean
  end

  def self.down
    remove_column :graphics, :inverted, :boolean
  end
end
