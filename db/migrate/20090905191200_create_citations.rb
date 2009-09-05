class CreateCitations < ActiveRecord::Migration
  def self.up
    create_table :citations do |t|
      t.integer :source_entry_id
      t.integer :cited_entry_id
      t.string :citation_type
      t.string :part_1
      t.string :part_2
      t.string :part_3
    end
    
    add_index :citations, [:source_entry_id, :citation_type, :cited_entry_id], :name => 'source_citation_cited'
  end

  def self.down
    drop_table :citations
  end
end
