class CreateLedePhotos < ActiveRecord::Migration
  def self.up
    add_column :entries, :lede_photo_id, :integer
    add_column :entries, :lede_photo_candidates, :text
    
    create_table :lede_photos do |t|
      t.string :credit
      t.string :credit_url
      
      t.string :photo_file_name
      t.string :photo_content_type
      t.integer :photo_file_size
      t.datetime :photo_updated_at
    end
  end

  def self.down
    drop_table :lede_photos
    remove_column :entries, :lede_photo_candidates
    remove_column :entries, :lede_photo_id
  end
end
