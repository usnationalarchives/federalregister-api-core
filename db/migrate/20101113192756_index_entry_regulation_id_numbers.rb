class IndexEntryRegulationIdNumbers < ActiveRecord::Migration
  def self.up
    add_index :entry_regulation_id_numbers, [:entry_id, :regulation_id_number], :name => "index"
  end

  def self.down
    remove_index :entry_regulation_id_numbers, :name => "index"
  end
end
