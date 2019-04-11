class AddIndexToCitations < ActiveRecord::Migration
  def self.up
    add_index :citations, [:cited_entry_id, :citation_type, :source_entry_id], :name => 'cited_citation_source'
  end

  def self.down
    remove_index :citations, :name => 'cited_citation_source'
  end
end
