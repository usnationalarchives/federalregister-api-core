class AddPackageIdentifierToGpoGraphic < ActiveRecord::Migration
  def self.up
    add_column :gpo_graphics, :package_identifier, :string
  end

  def self.down
    remove_column :gpo_graphics, :package_identifier
  end
end
