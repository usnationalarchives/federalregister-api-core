class AddStatisticsToSubscriptions < ActiveRecord::Migration
  def self.up
    add_column :subscriptions, :last_delivered_at, :datetime
    add_column :subscriptions, :delivery_count, :integer, :default => 0, :nil => false
  end

  def self.down
    remove_column :subscriptions, :last_delivered_at
    remove_column :subscriptions, :delivery_count
  end
end
