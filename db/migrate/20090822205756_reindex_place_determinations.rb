class ReindexPlaceDeterminations < ActiveRecord::Migration
  def self.up
    add_index :place_determinations, ["entry_id", "place_id"]
    add_index :place_determinations, ["place_id", "entry_id"]
  end

  def self.down
    remove_index :place_determinations, ["place_id", "entry_id"]
    remove_index :place_determinations, ["entry_id", "place_id"]
  end
end
