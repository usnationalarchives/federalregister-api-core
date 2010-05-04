class AddCuratedFieldsToEntry < ActiveRecord::Migration
  def self.up
    rename_column :entries, :headline, :curated_title
    create_column :entries, :curated_abstract, :string
  end

  def self.down
    drop_column :entries, :curated_abstract
    rename_column :entries, :curated_title, :headline
  end
end
