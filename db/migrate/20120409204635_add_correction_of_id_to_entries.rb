class AddCorrectionOfIdToEntries < ActiveRecord::Migration
  def self.up
    add_column :entries, :correction_of_id, :integer
    add_index :entries, :correction_of_id, :name => "index_entries_on_correction_of"

    execute "update entries, entries AS e set entries.correction_of_id = e.id
    where (entries.document_number like 'C%' or entries.document_number like 'R%')
    and entries.publication_date > '2008-01-01'
    and substring(entries.document_number, 4) = e.document_number"
  end

  def self.down
    remove_index :entries, :name => "index_entries_on_correction_of"
    remove_column :entries, :correction_of_id
  end
end
