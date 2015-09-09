class AddGpoGraphicUsages < ActiveRecord::Migration
  def self.up
    create_table :gpo_graphic_usages do |t|
      t.string :identifier
      t.string :document_number

      t.timestamps
    end
    add_index :gpo_graphic_usages, [:document_number, :identifier], :unique => true
    add_index :gpo_graphic_usages, [:identifier, :document_number]

  end

  def self.down
    drop_table :gpo_graphic_usages
  end
end
