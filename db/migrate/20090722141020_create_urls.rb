class CreateUrls < ActiveRecord::Migration
  def self.up
    create_table :urls do |t|
      t.string  :name, :type
      t.timestamps
    end
    add_index :urls, :name
    add_index :urls, :type
  end

  def self.down
    drop_table :urls
  end
end
