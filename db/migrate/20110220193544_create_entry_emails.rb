class CreateEntryEmails < ActiveRecord::Migration
  def self.up
    create_table :entry_emails do |t|
      t.string  :remote_ip,      :nil => false
      t.integer :num_recipients, :nil => false
      t.integer :entry_id,       :nil => false
      t.string  :sender_hash,    :nil => false

      t.timestamps
    end
  end

  def self.down
    drop_table :entry_emails
  end
end
