class CreateDocketNumbers < ActiveRecord::Migration
  def self.up
    create_table :docket_numbers do |t|
      t.string  :number
      t.string  :assignable_type
      t.integer :assignable_id
      t.integer :position, :default => 0, :null => false
    end

    add_index :docket_numbers, [:assignable_type, :assignable_id]

    connection.execute(<<-SQL)
      INSERT INTO docket_numbers (number, assignable_type, assignable_id, position)
      SELECT entries.docket_id, 'Entry', entries.id, 1
      FROM entries
      WHERE entries.docket_id IS NOT NULL AND entries.docket_id != ''
    SQL

    remove_column :entries, :docket_id
    remove_column :public_inspection_documents, :docket_id
    remove_column :public_inspection_documents, :internal_docket_id
  end

  def self.down
    drop_table :docket_numbers
    add_column :entries, :docket_id, :string
    add_column :public_inspection_documents, :docket_id, :string
    add_column :public_inspection_documents, :internal_docket_id, :string
  end
end
