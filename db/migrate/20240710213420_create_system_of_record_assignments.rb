class CreateSystemOfRecordAssignments < ActiveRecord::Migration[6.1]
  def up
    create_table :system_of_record_assignments, id: false do |t|
      t.belongs_to :system_of_record
      t.belongs_to :entry
      t.timestamps
    end
  end

  def down
    drop_table :system_of_record_assignments
  end
end
