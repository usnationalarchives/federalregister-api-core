class AddDateTypeToReferencedDates < ActiveRecord::Migration
  def self.up
    add_column :referenced_dates, :date_type, :string
    remove_column :referenced_dates, :prospective
    remove_column :entries, :effective_date
    remove_column :entries, :comment_period_ends_on
  end

  def self.down
    add_column :entries, :comment_period_ends_on, :date
    add_column :entries, :effective_date, :date
    add_column :referenced_dates, :prospective, :boolean
    remove_column :referenced_dates, :date_type
  end
end
