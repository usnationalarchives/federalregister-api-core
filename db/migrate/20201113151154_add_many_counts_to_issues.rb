class AddManyCountsToIssues < ActiveRecord::Migration[6.0]
  def change
    change_table :issues do |t|
      t.integer :rule_count
      t.integer :proposed_rule_count
      t.integer :notice_count
      t.integer :presidential_document_count
      t.integer :unknown_document_count
      t.integer :correction_count
      t.integer :rule_page_count
      t.integer :proposed_rule_page_count
      t.integer :notice_page_count
      t.integer :presidential_document_page_count
      t.integer :unknown_document_page_count
      t.integer :correction_page_count
      t.integer :blank_page_count
    end
  end
end
