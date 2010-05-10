class AddFurtherDetailsToLedePhotos < ActiveRecord::Migration
  def self.up
    add_column :lede_photos, :url, :string
    add_column :lede_photos, :crop_width, :integer
    add_column :lede_photos, :crop_height, :integer
    add_column :lede_photos, :crop_x, :integer
    add_column :lede_photos, :crop_y, :integer
  end

  def self.down
    remove_column :lede_photos, :url
    remove_column :lede_photos, :crop_width
    remove_column :lede_photos, :crop_height
    remove_column :lede_photos, :crop_x
    remove_column :lede_photos, :crop_y
  end
end
