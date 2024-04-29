class AddHistoricalPageViewCountToPublicInspectionDocuments < ActiveRecord::Migration[6.1]
  def change
    add_column :public_inspection_documents, :historical_page_view_count, :integer
  end
end
