class CreatePublicInspectionIssues < ActiveRecord::Migration
  def self.up
    create_table :public_inspection_issues do |t|
      t.date :publication_date
      t.datetime :published_at
      t.datetime :special_filings_updated_at
      t.datetime :regular_filings_updated_at
    end
    add_index :public_inspection_issues, [:published_at, :publication_date], "published_at_then_date"

    create_table :public_inspection_postings, :id => false do |t|
      t.integer :issue_id
      t.integer :document_id
    end
    add_index :public_inspection_postings, [:issue_id, :document_id]
  end

  def self.down
    drop_table :public_inspection_postings
    drop_table :public_inspection_issues
  end
end
