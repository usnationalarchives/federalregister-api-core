class AddEntryIdToPublicInspectionDocuments < ActiveRecord::Migration
  def self.up
    add_column :public_inspection_documents, :entry_id, :integer
    add_index :public_inspection_documents, :entry_id
  end

  def self.down
    remove_column :public_inspection_documents, :entry_id
  end
end
