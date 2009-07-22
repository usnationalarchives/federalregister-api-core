class CreateUrlReferences < ActiveRecord::Migration
  def self.up
    create_table :url_references do |t|
      t.belongs_to :url
      t.belongs_to :entry
      t.timestamps
    end
    add_index :url_references, :url_id
    add_index :url_references, :entry_id
  end

  def self.down
    drop_table :url_references
  end
end
