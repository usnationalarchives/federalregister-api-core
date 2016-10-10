class ChangePlaceDeterminationsConfidenceToFloat < ActiveRecord::Migration
  def self.up
    change_column :place_determinations, :confidence, :float
  end

  def self.down
    change_column :place_determinations, :confidence, :integer
  end
end
