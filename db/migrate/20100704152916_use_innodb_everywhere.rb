class UseInnodbEverywhere < ActiveRecord::Migration
  def self.up
    connection.select_values("SHOW TABLES").each do |table_name|
      puts "converting #{table_name} to INNODB..."
      connection.execute("ALTER TABLE #{table_name} TYPE = INNODB;")
    end
  end

  def self.down
  end
end
