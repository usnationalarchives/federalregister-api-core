class AddSearchTypeToMailingLists < ActiveRecord::Migration
  def self.up
    add_column :mailing_lists, :search_type, :string
    connection.execute("UPDATE mailing_lists SET search_type = 'Entry'")
  end

  def self.down
    remove_column :mailing_lists, :search_type
  end
end
