class AddDocumentNumberToEntryEmails < ActiveRecord::Migration
  def self.up
    add_column :entry_emails, :document_number, :string

    ActiveRecord::Base.connection.execute(<<-SQL)
      UPDATE entry_emails, entries
      SET entry_emails.document_number = entries.document_number
      WHERE entries.id = entry_emails.entry_id
    SQL
  end

  def self.down
    remove_column :document_number
  end
end
