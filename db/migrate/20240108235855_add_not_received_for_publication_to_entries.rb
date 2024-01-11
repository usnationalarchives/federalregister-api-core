class AddNotReceivedForPublicationToEntries < ActiveRecord::Migration[6.1]
  def change
    change_table(:entries) do |t|
      t.boolean :not_received_for_publication
      t.integer :president_id
    end
  end
end
