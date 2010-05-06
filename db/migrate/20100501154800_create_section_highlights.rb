class CreateSectionHighlights < ActiveRecord::Migration
  def self.up
    add_column :entries, :headline, :string
    
    create_table :section_highlights do |t|
      t.integer :section_id
      t.integer :entry_id
      t.integer :position
      t.date :publication_date
    end
    
    add_index :section_highlights, [:section_id, :entry_id]
  end

  def self.down
    drop_table :section_highlights
    remove_column :entries, :headline
  end
end
