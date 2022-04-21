class ImageSchemaModifications < ActiveRecord::Migration[6.1]
  def change
    add_column :images, :image_content_type, :string
    add_column :image_variants, :image_content_type, :string
    remove_column :image_variants, :parent_image_id
    
    # Add uniqueness constraints to image tables
    add_index :images, :identifier, unique: true
    add_index :image_variants, [:identifier, :style], unique: true
  end
end
