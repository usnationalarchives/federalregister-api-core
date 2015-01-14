class CreateIssues < ActiveRecord::Migration
  def self.up
    create_table :issues do |t|
      t.date :publication_date

      t.datetime :completed_at
      # t.datetime :approved_at
      # t.datetime :reapproved_at

      t.timestamps
    end

    execute "INSERT INTO issues (publication_date, completed_at) SELECT publication_date, MAX(updated_at) AS completed_at FROM entries GROUP BY publication_date"
  end

  def self.down
    drop_table :issues
  end
end
