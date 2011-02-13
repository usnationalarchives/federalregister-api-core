class MailingList < ApplicationModel
  validates_presence_of :search_conditions, :title
  has_many :subscriptions
  has_many :active_subscriptions,
           :class_name => "Subscription",
           :conditions => "subscriptions.confirmed_at IS NOT NULL and subscriptions.unsubscribed_at IS NULL"
  named_scope :active, :conditions => "active_subscriptions_count > 0"
  
  composed_of :search,
              :class_name => 'EntrySearch',
              :mapping => %w(search_conditions to_json)
  before_create :populate_title_based_on_search_summary
  
  def title
    self['title'] || search.summary
  end
  
  def populate_title_based_on_search_summary
    self.title = search.summary
  end
end