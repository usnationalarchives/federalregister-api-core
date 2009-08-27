class AddRegulationsdotgovIdToEntries < ActiveRecord::Migration
  def self.up
    add_column :entries, :regulationsdotgov_id, :string
  end

  def self.down
    remove_column :entries, :regulationsdotgov_id
  end
end
