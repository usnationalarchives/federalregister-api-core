class CreateFrNotices < ActiveRecord::Migration
  def self.up
    create_table :fr_notices do |t|
      t.string :type, :id, :link, :genre, :title, :part_name
      t.string :citation, :uri, :pdf_uri, :text_uri
      t.integer :length, :start_page, :end_page
      t.string :search_title, :granule_class, :access_id
      t.timestamps
    end
  end

  def self.down
    drop_table :fr_notices
  end
end
