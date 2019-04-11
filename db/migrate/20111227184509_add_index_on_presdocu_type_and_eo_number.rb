class AddIndexOnPresdocuTypeAndEoNumber < ActiveRecord::Migration
  def self.up
    add_index :entries, [:presidential_document_type_id, :executive_order_number], :name => "presdocu_type_id_and_eo_number"
    remove_index :entries, :presidential_document_type_id
  end

  def self.down
    add_index :entries, :presidential_document_type_id
    remove_index :entries, :name => "presdocu_type_id_and_eo_number"
  end
end
