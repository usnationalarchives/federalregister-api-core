class CreateEntryCfrAffectedParts < ActiveRecord::Migration
  def self.up
    create_table :entry_cfr_affected_parts do |t|
      t.integer :entry_id
      t.integer :title
      t.integer :part
    end

    execute "INSERT INTO entry_cfr_affected_parts (entry_id, title, part) SELECT id, cfr_title, cfr_part FROM entries WHERE cfr_title IS NOT NULL AND cfr_part IS NOT NULL"

    remove_column :entries, :cfr_title
    remove_column :entries, :cfr_part

    add_index :entry_cfr_affected_parts, :entry_id
  end

  def self.down
    add_column :entries, :cfr_title, :string
    add_column :entries, :cfr_part, :string
    drop_table :entry_cfr_affected_parts
  end
end
