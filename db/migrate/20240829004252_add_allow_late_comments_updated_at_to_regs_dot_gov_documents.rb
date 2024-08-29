class AddAllowLateCommentsUpdatedAtToRegsDotGovDocuments < ActiveRecord::Migration[6.1]
  def change
    add_column :regs_dot_gov_documents, :allow_late_comments_updated_at, :datetime
  end
end
