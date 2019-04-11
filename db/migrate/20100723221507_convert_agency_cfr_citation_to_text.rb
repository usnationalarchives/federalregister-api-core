class ConvertAgencyCfrCitationToText < ActiveRecord::Migration
  def self.up
    change_column :agencies, :cfr_citation, :text
  end

  def self.down
    change_column :agencies, :cfr_citation, :string
  end
end
