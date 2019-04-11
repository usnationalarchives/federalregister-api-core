class AddEntryCountsToAgencies < ActiveRecord::Migration
  def self.up
    add_column :agencies, :entries_count, :integer
    add_column :agencies, :entries_1_year_weekly, :text
    add_column :agencies, :entries_5_years_monthly, :text
    add_column :agencies, :entries_all_years_quarterly, :text
  end

  def self.down
    remove_column :agencies, :entries_count
    remove_column :agencies, :entries_1_year_weekly
    remove_column :agencies, :entries_5_years_monthly
    remove_column :agencies, :entries_all_years_quarterly
  end
end
