class RenameDocketsToRegsDotGovDockets < ActiveRecord::Migration[6.1]
  def change
    rename_table :dockets, :regs_dot_gov_dockets
  end
end
