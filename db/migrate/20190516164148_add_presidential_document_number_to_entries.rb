class AddPresidentialDocumentNumberToEntries < ActiveRecord::Migration

  def self.up
    add_column :entries, :presidential_document_number, :string
  end

  def self.down
    add_column :entries, :presidential_document_number
  end
end
