class AddXmlIdentifierToGpoGraphicUsages < ActiveRecord::Migration
  def self.up
    add_column :gpo_graphic_usages, :xml_identifier, :string
    add_index :gpo_graphic_usages, [:xml_identifier, :document_number]
    add_index :gpo_graphic_usages, [:document_number, :xml_identifier]
  end

  def self.down
    remove_column :gpo_graphic_usages, :xml_identifier, :string
  end
end
