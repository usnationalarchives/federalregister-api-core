class AddUniqueIndexToEntryChanges < ActiveRecord::Migration[6.0]
  def change
    add_index :entry_changes, :entry_id, unique: true
  end
end
