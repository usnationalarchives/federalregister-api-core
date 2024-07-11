class CreateSystemOfRecords < ActiveRecord::Migration[6.1]
  def change
    create_table :system_of_records do |t|
      t.string :name
      t.string :identifier
      t.timestamps
    end
  end
end
