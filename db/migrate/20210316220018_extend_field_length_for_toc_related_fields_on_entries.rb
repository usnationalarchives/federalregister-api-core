class ExtendFieldLengthForTocRelatedFieldsOnEntries < ActiveRecord::Migration[6.0]
  def change
    change_column :entries, :toc_subject, :string, :limit => 2000
    change_column :entries, :toc_doc, :string, :limit => 2000
  end
end
