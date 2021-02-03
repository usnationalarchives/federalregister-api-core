class AddTocNoteTitleAndTocNoteTextAndTocNoteActiveToIssues < ActiveRecord::Migration[6.0]
  def change
    change_table :issues do |t|
      t.string :toc_note_title
      t.text :toc_note_text
      t.boolean :toc_note_active, :default => true
    end
  end
end
