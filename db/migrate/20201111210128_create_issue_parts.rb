class CreateIssueParts < ActiveRecord::Migration[6.0]
  def change
    create_table :issue_parts do |t|
      t.integer :issue_id
      t.integer :start_page
      t.integer :end_page
      t.string :title
      t.string :initial_document_type
      t.timestamps
    end
    add_index :issue_parts, :issue_id
  end
end
