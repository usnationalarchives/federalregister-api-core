class CreateAgencies < ActiveRecord::Migration
  def self.up
    create_table :agencies do |t|
      t.integer :parent_id
      t.string  :name
      t.timestamps
    end
    add_index :agencies, :name
  end

  def self.down
    drop_table :agencies
  end
end
