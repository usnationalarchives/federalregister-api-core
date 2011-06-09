class AddRefererToEntryPageViews < ActiveRecord::Migration
  def up
    add_column :entry_page_views, :raw_referer, :text
    add_column :entry_page_views, :normalized_referer, :text
  end

  def down
    remove_column :entry_page_views, :raw_referer
    remove_column :entry_page_views, :normalized_referer
  end
end
