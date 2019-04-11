class RenameMailingListsParametersToSearchConditions < ActiveRecord::Migration
  def self.up
    rename_column :mailing_lists, :parameters, :search_conditions
  end

  def self.down
    rename_column :mailing_lists, :search_conditions, :parameters
  end
end
