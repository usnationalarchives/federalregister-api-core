class AddIndexToEvents < ActiveRecord::Migration
  def self.up
    remove_index :events, :event_type
    add_index :events, [:event_type, :entry_id, :date]
    add_index :events, [:event_type, :entry_id, :place_id]
    add_index :events, [:event_type, :place_id, :entry_id]
  end

  def self.down
    add_index :events, :event_type
    remove_index :events, [:event_type, :entry_id, :date]
    remove_index :events, [:event_type, :entry_id, :place_id]
    remove_index :events, [:event_type, :place_id, :entry_id]
  end
end
