class AddDocketIdIndexToRegsDotGovDocuments < ActiveRecord::Migration[6.1]
  def change
    add_index :regs_dot_gov_documents, :docket_id
  end
end
