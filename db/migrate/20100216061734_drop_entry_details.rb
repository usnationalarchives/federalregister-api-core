class DropEntryDetails < ActiveRecord::Migration
  def self.up
    drop_table :entry_details
  end

  def self.down
    create_table "entry_details" do |t|
      t.integer "entry_id"
      t.text    "full_text_raw", :limit => 2147483647
    end
  end
end
