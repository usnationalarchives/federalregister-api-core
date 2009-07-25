class CreateReferencedDates < ActiveRecord::Migration
  def self.up
    create_table :referenced_dates do |t|
      t.belongs_to :entry
      t.date :date
      t.string :string
      t.string :context
      t.boolean :prospective
      
      t.timestamps
    end
    
    add_index :referenced_dates, [:entry_id, :date]
  end

  def self.down
    drop_table :referenced_dates
  end
end
