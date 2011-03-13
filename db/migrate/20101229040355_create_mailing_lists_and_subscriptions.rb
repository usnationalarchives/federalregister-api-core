class CreateMailingListsAndSubscriptions < ActiveRecord::Migration
  def self.up
    create_table :mailing_lists do |t|
      t.text     :parameters
      t.string   :title
      t.integer  :active_subscriptions_count
      
      t.timestamps
    end
    
    create_table :subscriptions do |t|
      t.integer  :mailing_list_id
      t.string   :email
      t.string   :requesting_ip
      t.string   :token
      
      t.datetime :confirmed_at
      t.datetime :unsubscribed_at
      t.timestamps
    end
  end

  def self.down
    drop_table :subscriptions
    drop_table :mailing_lists
  end
end
