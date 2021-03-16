class ExtendFieldLengthForTocRelatedFieldsOnPil < ActiveRecord::Migration[6.0]
  def change
    change_column :public_inspection_documents, :subject_1, :string, :limit => 2000
    change_column :public_inspection_documents, :subject_2, :string, :limit => 2000
    change_column :public_inspection_documents, :subject_3, :string, :limit => 2000
  end
end
