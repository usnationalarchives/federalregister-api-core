class AddSornColumnsToEntries < ActiveRecord::Migration[6.1]
  def change
    change_table :entries do |t|
      t.string :sorn_system_name
      t.string :sorn_system_number
      t.integer :notice_type_id
    end
  end
end
