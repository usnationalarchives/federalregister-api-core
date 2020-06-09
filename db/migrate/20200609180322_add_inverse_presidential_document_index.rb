class AddInversePresidentialDocumentIndex < ActiveRecord::Migration[6.0]
  def change
    add_index "entries",
      ["presidential_document_number","presidential_document_type_id"],
      :name   => "pres_doc_number_pres_doc_type_id",
      :length => {
        "presidential_document_number"  => 10, #NOTE: Mysql seems to have a limit of 767 bytes for an index, hence the need to limit the length of this text field
        "presidential_document_type_id" => nil,
      }
  end
end
