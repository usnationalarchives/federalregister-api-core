class CreatePilAgencyLetters < ActiveRecord::Migration[6.0]
  def change
    create_table :pil_agency_letters do |t|
      t.integer :public_inspection_document_id

      t.index :public_inspection_document_id
    end

  end
end
