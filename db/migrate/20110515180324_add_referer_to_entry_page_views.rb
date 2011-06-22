class AddRefererToEntryPageViews < ActiveRecord::Migration
  def self.up
    add_column :entry_page_views, :raw_referer, :text
    add_column :entry_page_views, :normalized_referer, :text
  end

  def self.down
    remove_column :entry_page_views, :raw_referer
    remove_column :entry_page_views, :normalized_referer
  end
end
