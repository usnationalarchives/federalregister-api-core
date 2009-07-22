class CreateEntries < ActiveRecord::Migration
  def self.up
    create_table :entries do |t|
      t.string  :type, :identifier, :link, :genre, :title, :part_name, :citation, :abstract
      t.integer :length, :start_page, :end_page
      t.string  :search_title, :granule_class, :document_number
      t.string  :effective_date, :action, :dates, :contact
      t.string  :toc_subject, :toc_doc
      t.timestamps
    end
  end

  def self.down
    drop_table :entries
  end
end
