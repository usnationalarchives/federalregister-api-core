class AddDigestToGraphicStyles < ActiveRecord::Migration[6.1]
  def change
    add_column :graphic_styles, :digest, :string
  end
end
