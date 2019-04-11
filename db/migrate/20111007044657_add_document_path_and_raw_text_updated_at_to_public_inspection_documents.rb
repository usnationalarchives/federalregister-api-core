class AddDocumentPathAndRawTextUpdatedAtToPublicInspectionDocuments < ActiveRecord::Migration
  def self.up
    add_column :public_inspection_documents, :document_file_path, :string
    add_column :public_inspection_documents, :raw_text_updated_at, :datetime
  end

  def self.down
    remove_column :public_inspection_documents, :raw_text_updated_at
    remove_column :public_inspection_documents, :document_file_path
  end
end
