class AddRegulationsDotGovDocumentIdIndex < ActiveRecord::Migration[6.1]
  def change
    add_index :regs_dot_gov_documents, :regulations_dot_gov_document_id
  end
end
