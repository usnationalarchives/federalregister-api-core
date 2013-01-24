class AddIndexToDockets < ActiveRecord::Migration
  def self.up
    execute(<<-SQL)
      CREATE TEMPORARY TABLE dockets_temp
      SELECT *
      FROM dockets
      GROUP BY id;
    SQL

    execute("TRUNCATE dockets")
    execute("INSERT INTO dockets SELECT * from dockets_temp")
    execute("DROP TABLE dockets_temp")

    execute("ALTER TABLE dockets ADD PRIMARY KEY (id)")
  end

  def self.down
    execute("ALTER TABLE dockets DROP PRIMARY KEY (id)")
  end
end
