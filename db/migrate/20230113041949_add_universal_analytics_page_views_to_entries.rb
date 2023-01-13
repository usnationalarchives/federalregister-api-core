class AddUniversalAnalyticsPageViewsToEntries < ActiveRecord::Migration[6.1]
  def change
    add_column :entries, :universal_analytics_page_views, :integer
  end
end
