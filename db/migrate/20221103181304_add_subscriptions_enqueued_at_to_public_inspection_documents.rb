class AddSubscriptionsEnqueuedAtToPublicInspectionDocuments < ActiveRecord::Migration[6.1]
  def change
    add_column :public_inspection_documents, :subscriptions_enqueued_at, :datetime
  end
end
