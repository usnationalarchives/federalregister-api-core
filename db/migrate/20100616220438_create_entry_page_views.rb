class CreateEntryPageViews < ActiveRecord::Migration
  def self.up
    create_table :entry_page_views do |t|
      t.integer :entry_id, :nil => false
      t.datetime :created_at, :nil => false
      t.string :remote_ip, :nil => false
    end

    add_index :entry_page_views, :entry_id
  end

  def self.down
    drop_table :entry_page_views
  end
end
