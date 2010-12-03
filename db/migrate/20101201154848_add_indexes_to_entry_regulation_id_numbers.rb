class AddIndexesToEntryRegulationIdNumbers < ActiveRecord::Migration
  def self.up
    add_index :entry_regulation_id_numbers, [:regulation_id_number, :entry_id], :name => "rin_then_entry"
  end

  def self.down
    remove_index :entry_regulation_id_numbers, [:regulation_id_number, :entry_id], :name => "rin_then_entry"
  end
end
