class ChangeDocketTitleColumnCharacterSet < ActiveRecord::Migration[6.0]
  def change
    ActiveRecord::Base.connection.execute("ALTER TABLE dockets MODIFY title VARCHAR(255) CHARACTER SET utf8mb4;")
  end

  def down
    ActiveRecord::Base.connection.execute("ALTER TABLE dockets MODIFY title VARCHAR(255) CHARACTER SET latin1;")
  end
end
