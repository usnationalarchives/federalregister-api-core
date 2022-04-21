class CreateImages < ActiveRecord::Migration[6.1]
  def change
    create_table :images do |t|
      t.string :identifier
      t.string :image_file_name
      t.integer :image_height
      t.string :image_sha
      t.integer :image_size
      t.integer :image_width
      t.datetime :made_public_at
      t.integer :source_id
      t.timestamps
    end
  end
end
