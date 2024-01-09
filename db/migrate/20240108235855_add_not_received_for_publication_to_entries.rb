class AddNotReceivedForPublicationToEntries < ActiveRecord::Migration[6.1]
  def change
    add_column :entries, :not_received_for_publication, :boolean
  end
end
