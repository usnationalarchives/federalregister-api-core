class AddExecutiveOrderNotesToEntries < ActiveRecord::Migration
  def self.up
    add_column :entries, :executive_order_notes, :text
  end

  def self.down
    remove_column :entries, :executive_order_notes
  end
end
