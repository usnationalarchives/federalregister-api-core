class AddTimestampsToPublicInspectionIssues < ActiveRecord::Migration
  def self.up
    add_column :public_inspection_issues, :created_at, :datetime
    add_column :public_inspection_issues, :updated_at, :datetime
    add_column :public_inspection_documents, :created_at, :datetime
    add_column :public_inspection_documents, :updated_at, :datetime
  end

  def self.down
    remove_column :public_inspection_issues, :created_at
    remove_column :public_inspection_issues, :updated_at
    remove_column :public_inspection_documents, :created_at
    remove_column :public_inspection_documents, :updated_at
  end
end
