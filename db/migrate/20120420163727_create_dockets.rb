class CreateDockets < ActiveRecord::Migration
  def self.up
    create_table :dockets, :id => false do |t|
      t.string :id, :primary => true
      t.string :regulation_id_number
      t.integer :comments_count
      t.integer :docket_documents_count
      t.string :title
      t.text :metadata
    end

    create_table :docket_documents, :id => false do |t|
      t.string :id, :primary => true
      t.string :docket_id
      t.string :title
      t.text   :metadata
    end

    add_index :docket_documents, :docket_id

    add_column :entries, :regulations_dot_gov_docket_id, :string
  end

  def self.down
    drop_table :dockets
    drop_table :docket_documents
  end
end
