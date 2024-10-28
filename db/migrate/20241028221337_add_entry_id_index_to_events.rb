class AddEntryIdIndexToEvents < ActiveRecord::Migration[6.1]
  def change
    add_index :events, :entry_id
  end
end
