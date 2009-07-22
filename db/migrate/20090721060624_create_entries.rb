class CreateEntries < ActiveRecord::Migration
  def self.up
    create_table :entries do |t|
      t.text :title, :abstract, :contact, :dates, :action
      t.string  :type, :identifier, :link, :genre, :part_name, :citation
      t.string  :granule_class, :document_number, :toc_subject, :toc_doc
      t.integer :length, :start_page, :end_page
      t.date :publication_date, :effective_date
      
      t.timestamps
    end
    
    add_index :entries, :identifier
    add_index :entries, :document_number
  end

  def self.down
    drop_table :entries
  end
end
