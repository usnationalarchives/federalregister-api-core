class RenameMailingListsSearchTypeToType < ActiveRecord::Migration
  def self.up
    rename_column :mailing_lists, :search_type, :type
    connection.execute("UPDATE mailing_lists SET type = 'MailingList::Entry' WHERE type = 'Entry'")
    connection.execute("UPDATE mailing_lists SET type = 'MailingList::PublicInspectionDocument' WHERE type = 'PublicInspectionDocument'")
  end

  def self.down
    rename_column :mailing_lists, :type, :search_type
  end
end
