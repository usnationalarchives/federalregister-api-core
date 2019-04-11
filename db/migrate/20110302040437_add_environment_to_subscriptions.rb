class AddEnvironmentToSubscriptions < ActiveRecord::Migration
  def self.up
    add_column :subscriptions, :environment, :string
    execute "UPDATE subscriptions SET environment = 'development'"
  end

  def self.down
    remove_column :subscriptions, :environment
  end
end
