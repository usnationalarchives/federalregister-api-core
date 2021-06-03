class CreateGraphicStyles < ActiveRecord::Migration[6.0]
  def change
    create_table :graphic_styles do |t|
      t.integer :graphic_id
      t.integer :height
      t.integer :width
      t.string  :graphic_type
      t.string  :image_format
      t.string  :image_identifier
      t.string  :style_name
      t.timestamps
      t.index   :graphic_id
    end
  end
end
