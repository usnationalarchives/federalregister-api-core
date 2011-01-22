class MailingList < ApplicationModel
  validates_presence_of :parameters, :title
  has_many :subscriptions
  has_many :active_subscriptions,
           :class_name => "Subscription"
           :conditions => "subscriptions.confirmed_at IS NOT NULL and subscriptions.unsubscribed_at IS NULL"
  named_scope :active, :conditions => "active_subscriptions_count > 0"
end