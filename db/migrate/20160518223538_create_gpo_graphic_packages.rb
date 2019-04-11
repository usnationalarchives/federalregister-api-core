class CreateGpoGraphicPackages < ActiveRecord::Migration
  def self.up
    create_table :gpo_graphic_packages do |t|
      t.string :graphic_identifier
      t.string :package_identifier
      t.date :package_date
      t.timestamps
    end

    add_index :gpo_graphic_packages, :graphic_identifier
    add_index :gpo_graphic_packages, :package_identifier
    add_index :gpo_graphic_packages, :package_date
  end

  def self.down
    drop_table :gpo_graphic_packages
  end
end
