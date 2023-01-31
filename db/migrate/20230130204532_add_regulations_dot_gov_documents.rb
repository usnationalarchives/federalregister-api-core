class AddRegulationsDotGovDocuments < ActiveRecord::Migration[6.1]
  def change
    create_table :regs_dot_gov_documents do |t|
      t.boolean :allow_late_comments
      t.integer :comment_count
      t.date :comment_end_date
      t.date :comment_start_date
      t.string :deleted_at
      t.string :docket_id
      t.string :regulations_dot_gov_document_id 
      t.string :federal_register_document_number
      t.string :original_federal_register_document_number
      t.string :regulations_dot_gov_object_id
      t.timestamps
    end
    add_index :regs_dot_gov_documents, [:federal_register_document_number, :deleted_at], name: [:document_number_deleted_at]
  end
end
