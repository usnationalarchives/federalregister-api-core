class CreateGeneratedFiles < ActiveRecord::Migration
  def self.up
    create_table :generated_files do |t|
      t.string :parameters
      t.string :token

      t.datetime :processing_began_at
      t.datetime :processing_completed_at

      t.string :attachment_file_name
      t.string :attachment_file_type
      t.integer :attachment_file_size
      t.datetime :attachment_updated_at

      t.userstamps
      t.timestamps
    end
  end

  def self.down
    drop_table :generated_files
  end
end
