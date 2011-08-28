class CreateCannedSearches < ActiveRecord::Migration
  def self.up
    create_table :canned_searches do |t|
      t.integer :section_id
      t.string  :title
      t.string  :slug
      t.text    :description
      t.text    :search_conditions
      t.boolean :active
      t.integer :position
    end
    add_index :canned_searches, :slug
    add_index :canned_searches, [:section_id, :active]
  end

  def self.down
    drop_table :canned_searches
  end
end
