class CreatePublicInspectionDocuments < ActiveRecord::Migration
  def self.up
    create_table :public_inspection_documents do |t|
      t.string   :document_number
      t.string   :granule_class
      t.datetime :filed_at
      t.date     :publication_date
      t.string   :docket_id
      t.string   :internal_docket_id
      t.string   :toc_subject
      t.string   :toc_doc
      t.boolean  :special_filing, :default => false, :null => false
      t.string   :pdf_file_name
      t.integer  :pdf_file_size
      t.datetime :pdf_updated_at
      t.string   :pdf_etag
    end
    add_index :public_inspection_documents, :document_number
    add_index :public_inspection_documents, :publication_date
  end

  def self.down
    drop_table :public_inspection_documents
  end
end
