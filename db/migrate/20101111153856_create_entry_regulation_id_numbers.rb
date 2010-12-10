class CreateEntryRegulationIdNumbers < ActiveRecord::Migration
  def self.up
    create_table :entry_regulation_id_numbers do |t|
      t.integer :entry_id
      t.string :regulation_id_number
    end
    
    execute "INSERT INTO entry_regulation_id_numbers (entry_id, regulation_id_number) SELECT id, regulation_id_number FROM entries WHERE regulation_id_number IS NOT NULL"
    
    remove_column :entries, :regulation_id_number
  end

  def self.down
    add_column :entries, :regulation_id_number, :string
    
    execute "UPDATE entries, entry_regulation_id_numbers SET entries.regulation_id_number = entry_regulation_id_numbers.regulation_id_number WHERE entries.id = entry_regulation_id_numbers.entry_id"
    
    drop_table :entry_regulation_id_numbers
  end
end
