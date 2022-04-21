class AddConstraintToImageUsages < ActiveRecord::Migration[6.1]
  def change
    add_index :image_usages, [:document_number, :identifier], unique: true
  end
end
