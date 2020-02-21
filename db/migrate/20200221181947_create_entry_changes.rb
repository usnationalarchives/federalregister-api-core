class CreateEntryChanges < ActiveRecord::Migration[6.0]
  def change
    create_table :entry_changes do |t|
      t.integer :entry_id
    end
  end
end
