class AddRegulationsDotGovOpenForCommentToRegsDotGovDocuments < ActiveRecord::Migration[6.1]
  def change
    add_column :regs_dot_gov_documents, :regulations_dot_gov_open_for_comment, :boolean
  end
end
