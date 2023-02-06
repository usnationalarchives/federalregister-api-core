class RenameDocketDocumentsToRegsDotGovSupportingDocuments < ActiveRecord::Migration[6.1]
  def change
    rename_table :docket_documents, :regs_dot_gov_supporting_documents
  end
end
