class RemoveSphinxDeltaColumns < ActiveRecord::Migration[6.0]
  def change
    change_table(:entries) do |t|
      t.remove :delta
    end

    change_table(:public_inspection_documents) do |t|
      t.remove :delta
    end
  end
end
