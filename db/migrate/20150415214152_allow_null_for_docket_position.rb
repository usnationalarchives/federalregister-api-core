class AllowNullForDocketPosition < ActiveRecord::Migration
  def self.up
    change_column :docket_numbers, :position, :integer, :null => true
  end

  def self.down
    change_column :docket_numbers, :position, :integer, :null => false
  end
end
