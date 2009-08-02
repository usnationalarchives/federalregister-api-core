class AddMoreDetailsToEntries < ActiveRecord::Migration
  def self.up
    add_column :entries, :source_text_url, :string
    
    add_column :entries, :primary_agency_raw, :string
    add_column :entries, :secondary_agency_raw, :string
  end

  def self.down
    remove_column :entries, :secondary_agency_raw
    remove_column :entries, :primary_agency_raw
    
    remove_column :entries, :source_text_url
  end
end
