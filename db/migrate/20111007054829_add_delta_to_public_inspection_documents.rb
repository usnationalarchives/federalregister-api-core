class AddDeltaToPublicInspectionDocuments < ActiveRecord::Migration
  def self.up
    add_column :public_inspection_documents, :delta, :boolean, :default => true, :null => false
    add_index :public_inspection_documents, :delta
  end

  def self.down
  end
end
