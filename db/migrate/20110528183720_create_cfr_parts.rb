class CreateCfrParts < ActiveRecord::Migration
  def self.up
    create_table :cfr_parts do |t|
      t.integer :year
      t.integer :title
      t.integer :part
      t.integer :volume
      t.string  :name, :length => 1000
    end
    
    add_index :cfr_parts, [:year, :title, :part]
  end

  def self.down
    drop_table :cfr_parts
  end
end
