class AddHistoricalPageViewCountToEntries < ActiveRecord::Migration[6.1]
  def change
    add_column :entries, :historical_page_view_count, :integer
  end
end
