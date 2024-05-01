class AddUniversalAnalyticsPageViewsToPublicInspectionDocuments < ActiveRecord::Migration[6.1]
  def change
    add_column :public_inspection_documents, :universal_analytics_page_views, :integer
  end
end
