class RemoveLegacyPresidentialDocColumns < ActiveRecord::Migration[4.2]

  def self.up
    change_table(:entries) do |t|
      t.remove_index name: 'index_entries_on_proclamation_number'
      t.remove_index name: 'presdocu_type_id_and_eo_number'
      t.remove :executive_order_number
      t.remove :proclamation_number
    end

    add_index "entries",
      ["presidential_document_type_id", "presidential_document_number"],
      :name   => "presidential_document_type_id",
      :length => {
        "presidential_document_type_id" => nil,
        "presidential_document_number"  => 10 #NOTE: Mysql seems to have a limit of 767 bytes for an index, hence the need to limit the length of this text field
      }
  end

  def self.down
    raise NotImplementedError
  end

end
