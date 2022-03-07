class AddDocumentIdIndexOnPublicInspectionPostings < ActiveRecord::Migration[6.1]
  def change
    add_index :public_inspection_postings, :document_id
  end
end
