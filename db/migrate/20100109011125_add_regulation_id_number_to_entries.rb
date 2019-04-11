class AddRegulationIdNumberToEntries < ActiveRecord::Migration
  def self.up
    add_column :entries, :regulation_id_number, :string
    add_index :entries, :regulation_id_number
  end

  def self.down
    remove_column :entries, :regulation_id_number
  end
end
