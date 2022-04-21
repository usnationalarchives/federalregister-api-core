class CreateImageVariants < ActiveRecord::Migration[6.1]
  def change
    create_table :image_variants do |t|
      t.string :identifier
      t.string :style
      t.string :image_file_name
      t.integer :image_height
      t.string :image_sha
      t.integer :image_size
      t.integer :image_width
      t.integer :parent_image_id
      t.timestamps
    end
  end
end
