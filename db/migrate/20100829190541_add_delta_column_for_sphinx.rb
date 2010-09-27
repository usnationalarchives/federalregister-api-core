class AddDeltaColumnForSphinx < ActiveRecord::Migration
  def self.up
    # entries already had a delta column
    add_index :entries, :delta
    add_column :events, :delta, :boolean, :default => true, :null => false
    add_index :events, :delta
    add_column :regulatory_plans, :delta, :boolean, :default => true, :null => false
    add_index :regulatory_plans, :delta
  end

  def self.down
    remove_column :regulatory_plans, :delta
    remove_column :events, :delta
    remove_column :entries, :delta
  end
end
