class ChangeFrIndexDocCharLimit < ActiveRecord::Migration[6.1]
  def change
    change_column :entries, :fr_index_doc, :string, limit: 1023
  end
end
