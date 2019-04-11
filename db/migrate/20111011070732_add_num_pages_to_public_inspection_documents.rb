class AddNumPagesToPublicInspectionDocuments < ActiveRecord::Migration
  def self.up
    add_column :public_inspection_documents, :num_pages, :integer
  end

  def self.down
    remove_column :public_inspection_documents, :num_pages
  end
end
