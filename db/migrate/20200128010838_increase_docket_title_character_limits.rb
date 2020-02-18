class IncreaseDocketTitleCharacterLimits < ActiveRecord::Migration[6.0]

  def change
    change_column :dockets, :title, :string, :limit => 1000
    change_column :docket_documents, :title, :string, :limit => 1000
  end

end
