class FixCommasOnExistingTocDocs < ActiveRecord::Migration
  def self.up
    connection.execute("UPDATE entries SET toc_doc = TRIM(TRAILING '\n' FROM TRIM(TRAILING ', ' FROM toc_doc)) WHERE toc_doc IS NOT NULL AND toc_doc LIKE '%, '")
  end

  def self.down
  end
end
