class AddSourcedViaEcfrDotGovToGpoGraphics < ActiveRecord::Migration[6.0]
  def change
    add_column :gpo_graphics, :sourced_via_ecfr_dot_gov, :boolean, null: false, default: false
  end
end
