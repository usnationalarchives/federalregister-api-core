class AddRegulationsdotgovInfoToEntries < ActiveRecord::Migration
  def self.up
    add_column :entries, :regulationsdotgov_id, :string
    add_column :entries, :comment_url, :string
    add_column :entries, :checked_regulationsdotgov_at, :datetime
  end

  def self.down
    remove_column :entries, :regulationsdotgov_id
    remove_column :entries, :comment_url
    remove_column :entries, :checked_regulationsdotgov_at
  end
end
