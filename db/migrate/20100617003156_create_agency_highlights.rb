class CreateAgencyHighlights < ActiveRecord::Migration
  def self.up
    create_table :agency_highlights do |t|
      t.integer :entry_id
      t.integer :agency_id
      t.date    :highlight_until
      t.boolean :published, :default => false
      t.string  :section_header
      t.string  :title
      t.string  :abstract
    end

    add_index :agency_highlights, :highlight_until
  end

  def self.down
    drop_table :agency_highlights
  end
end
