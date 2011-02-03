class RenameRegulationsdotgovIdToRegulationsdotgovUrl < ActiveRecord::Migration
  def self.up
    rename_column :entries, :regulationsdotgov_id, :regulationsdotgov_url
    execute "UPDATE entries SET regulationsdotgov_url = CONCAT('http://www.regulations.gov/search/Regs/home.html#documentDetail?R=', regulationsdotgov_url) WHERE regulationsdotgov_url IS NOT NULL"
  end

  def self.down
    rename_column :entries, :regulationsdotgov_url, :regulationsdotgov_id
  end
end
