class AddAdditionalCitationIndexToEntries < ActiveRecord::Migration[6.1]
  def change
    add_index :entries, [:volume, :end_page, :start_page]
  end
end
