class DefaultMailingListActiveSubscriptionCountTo0 < ActiveRecord::Migration
  def self.up
    change_column :mailing_lists, :active_subscriptions_count, :integer, :nil => false, :default => 0
  end

  def self.down
    change_column :mailing_lists, :active_subscriptions_count, :integer, :nil => true, :default => nil
  end
end
