class AddCitingEntriesCountToEntries < ActiveRecord::Migration
  def self.up
    add_column :entries, :citing_entries_count, :integer, :default => 0
    execute <<-SQL
      DROP TABLE IF EXISTS citation_counts;
      
      CREATE TEMPORARY TABLE citation_counts
      AS SELECT cited_entry_id, COUNT(*) AS count
         FROM citations
         GROUP BY cited_entry_id;
      
      ALTER TABLE citation_counts ADD UNIQUE (cited_entry_id);
      
      UPDATE entries, citation_counts
      SET entries.citing_entries_count = citation_counts.count
      WHERE entries.id = citation_counts.cited_entry_id
    SQL
    add_index :entries, :citing_entries_count
    add_index :entries, [:agency_id, :citing_entries_count]
  end

  def self.down
    remove_column :entries, :citing_entries_count
  end
end
