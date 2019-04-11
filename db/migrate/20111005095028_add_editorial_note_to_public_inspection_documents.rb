class AddEditorialNoteToPublicInspectionDocuments < ActiveRecord::Migration
  def self.up
    add_column :public_inspection_documents, :editorial_note, :text
  end

  def self.down
    remove_column :public_inspection_documents, :editorial_note
  end
end
