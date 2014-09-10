class SupportNewStructureForPublicInspectionDocs < ActiveRecord::Migration
  def self.up
    add_column :public_inspection_documents, :subject_1, :string
    add_column :public_inspection_documents, :subject_2, :string
    add_column :public_inspection_documents, :subject_3, :string

    execute <<-SQL
      UPDATE public_inspection_documents
      SET subject_1 = title
      WHERE title != ''
    SQL

    execute <<-SQL
      UPDATE public_inspection_documents
      SET subject_1 = toc_subject,
        subject_2 = toc_doc
      WHERE toc_subject IS NOT NULL AND toc_subject != ''
    SQL

    remove_column :public_inspection_documents, :title
    remove_column :public_inspection_documents, :toc_subject
    remove_column :public_inspection_documents, :toc_doc

    remove_column :public_inspection_documents, :pdf_etag
    add_column :public_inspection_documents, :pdf_url, :string
    add_column :public_inspection_documents, :category, :string
    add_column :public_inspection_documents, :update_pil_at, :datetime
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
