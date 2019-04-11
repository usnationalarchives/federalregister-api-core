class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.integer :entry_id
      t.date    :date
      t.string  :title
      t.integer :place_id
      t.boolean :remote_call_in_available
    end
  end

  def self.down
    drop_table :events
  end
end
