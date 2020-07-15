class AddCommentsCountAndRegulationsDotGovDocumentIdToEntries < ActiveRecord::Migration[6.0]
  def change
    change_table :entries do |t|
      t.string :regulations_dot_gov_document_id
      t.integer :comment_count
    end
  end
end
