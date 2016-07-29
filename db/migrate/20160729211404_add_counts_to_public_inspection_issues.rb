class AddCountsToPublicInspectionIssues < ActiveRecord::Migration
  def self.up
    add_column :public_inspection_issues, :special_filing_documents_count, :integer
    add_column :public_inspection_issues, :special_filing_agencies_count, :integer
    add_column :public_inspection_issues, :regular_filing_documents_count, :integer
    add_column :public_inspection_issues, :regular_filing_agencies_count, :integer

    PublicInspectionIssue.find_each do |issue|
      issue.calculate_counts
      issue.save
    end
  end

  def self.down
    remove_column :public_inspection_issues, :special_filing_documents_count
    remove_column :public_inspection_issues, :special_filing_agencies_count
    remove_column :public_inspection_issues, :regular_filing_documents_count
    remove_column :public_inspection_issues, :regular_filing_agencies_count
  end
end
