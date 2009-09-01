class AddVolumeToEntries < ActiveRecord::Migration
  def self.up
    add_column :entries, :volume, :integer
    
    execute "UPDATE entries SET volume = citation"
    
    add_index :entries, [:volume, :start_page, :end_page]
  end

  def self.down
    remove_column :entries, :volume
  end
end
