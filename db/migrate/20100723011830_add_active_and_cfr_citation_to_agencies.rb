class AddActiveAndCfrCitationToAgencies < ActiveRecord::Migration
  def self.up
    add_column :agencies, :active, :boolean
    add_column :agencies, :cfr_citation, :string
  end

  def self.down
    remove_column :agencies, :cfr_citation
    remove_column :agencies, :active
  end
end
