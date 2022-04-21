class CreateImageUsages < ActiveRecord::Migration[6.1]
  def change
    create_table :image_usages do |t|
      t.string :identifier
      t.string :document_number
      t.string :xml_identifier
      t.timestamps
    end
  end
end
