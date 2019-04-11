class ExtendPilSubjectColumnLength < ActiveRecord::Migration
  def self.up
    change_column :public_inspection_documents, :subject_1, :string, :limit => 1000
    change_column :public_inspection_documents, :subject_2, :string, :limit => 1000
    change_column :public_inspection_documents, :subject_3, :string, :limit => 1000
  end

  def self.down
    change_column :public_inspection_documents, :subject_1, :string, :limit => 255
    change_column :public_inspection_documents, :subject_2, :string, :limit => 255
    change_column :public_inspection_documents, :subject_3, :string, :limit => 255
  end
end
