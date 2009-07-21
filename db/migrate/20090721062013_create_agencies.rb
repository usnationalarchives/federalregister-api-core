class CreateAgencies < ActiveRecord::Migration
  def self.up
    create_table :agencies do |t|
      t.integer :parent_id
      t.string  :name
      t.timestamps
    end
  end

  def self.down
    drop_table :fr_notices
  end
end
