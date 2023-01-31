class AddAgencyIdToRegsDotGovDockets < ActiveRecord::Migration[6.1]
  def change
    add_column :regs_dot_gov_dockets, :agency_id, :string
  end
end
