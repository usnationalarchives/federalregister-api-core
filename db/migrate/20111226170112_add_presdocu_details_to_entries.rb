class AddPresdocuDetailsToEntries < ActiveRecord::Migration
  def self.up
    add_column :entries, :presidential_document_type_id, :integer
    add_column :entries, :signing_date, :date
    add_column :entries, :executive_order_number, :integer

    add_index :entries, :presidential_document_type_id
  end

  def self.down
    remove_index :entries, :presidential_document_type_id

    remove_column :entries, :executive_order_number
    remove_column :entries, :signing_date
    remove_column :entries, :presidential_document_type_id
  end
end
