class AddTitleToPublicInspectionDocuments < ActiveRecord::Migration
  def self.up
    add_column :public_inspection_documents, :title, :string, :null => false, :default => ''
  end

  def self.down
    remove_column :public_inspection_documents, :title
  end
end
