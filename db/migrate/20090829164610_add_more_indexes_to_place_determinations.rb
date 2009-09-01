class AddMoreIndexesToPlaceDeterminations < ActiveRecord::Migration
  def self.up
    remove_index "place_determinations", :name => "index_place_determinations_on_entry_id_and_confidence"
    remove_index "place_determinations", :name => "index_place_determinations_on_entry_id_and_place_id"
    remove_index "place_determinations", :name => "index_place_determinations_on_place_id_and_confidence"
    remove_index "place_determinations", :name => "index_place_determinations_on_place_id_and_entry_id"
    
    add_index "place_determinations", ["entry_id", "confidence", "place_id"], :name => "index_place_determinations_on_entry_id_and_place_id"
    add_index "place_determinations", ["place_id", "confidence", "entry_id"], :name => "index_place_determinations_on_place_id_and_entry_id"
  end

  def self.down
    remove_index "place_determinations", :name => "index_place_determinations_on_entry_id_and_place_id"
    remove_index "place_determinations", :name => "index_place_determinations_on_place_id_and_entry_id"

    add_index "place_determinations", ["entry_id", "confidence"], :name => "index_place_determinations_on_entry_id_and_confidence"
    add_index "place_determinations", ["entry_id", "place_id"], :name => "index_place_determinations_on_entry_id_and_place_id"
    add_index "place_determinations", ["place_id", "confidence"], :name => "index_place_determinations_on_place_id_and_confidence"
    add_index "place_determinations", ["place_id", "entry_id"], :name => "index_place_determinations_on_place_id_and_entry_id"
  end
end
