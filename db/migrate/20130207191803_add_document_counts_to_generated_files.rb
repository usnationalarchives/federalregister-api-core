class AddDocumentCountsToGeneratedFiles < ActiveRecord::Migration
  def self.up
    add_column :generated_files, :total_document_count, :integer
    add_column :generated_files, :processed_document_count, :integer
  end

  def self.down
    remove_column :generated_files, :total_document_count
    remove_column :generated_files, :processed_document_count
  end
end
