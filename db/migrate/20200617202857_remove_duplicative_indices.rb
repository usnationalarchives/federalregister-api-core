class RemoveDuplicativeIndices < ActiveRecord::Migration[6.0]
  def change
    remove_index :entries, name: :index_entries_on_agency_id_and_citing_entries_count
    remove_index :entries, name: :index_entries_on_publication_date_and_agency_id
  end
end
