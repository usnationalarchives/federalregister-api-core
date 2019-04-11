class AddCommentDateToEntries < ActiveRecord::Migration
  def self.up
    add_column :entries, :comment_period_ends_on, :date
  end

  def self.down
    remove_column :entries, :comment_period_ends_on
  end
end
