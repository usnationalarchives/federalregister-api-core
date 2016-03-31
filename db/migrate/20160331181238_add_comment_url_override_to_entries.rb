class AddCommentUrlOverrideToEntries < ActiveRecord::Migration
  def self.up
    add_column :entries, :comment_url_override, :string
  end

  def self.down
    remove_column :entries, :comment_url_override
  end
end
