=begin Schema Information

 Table name: mailing_lists

  id                         :integer(4)      not null, primary key
  search_conditions          :text
  title                      :string(255)
  active_subscriptions_count :integer(4)      default(0)
  created_at                 :datetime
  updated_at                 :datetime

=end Schema Information

class MailingList < ApplicationModel
  validates_presence_of :search_conditions, :title
  has_many :subscriptions
  has_many :active_subscriptions,
           :class_name => "Subscription",
           :conditions => "subscriptions.confirmed_at IS NOT NULL and subscriptions.unsubscribed_at IS NULL"
  named_scope :active, :conditions => "active_subscriptions_count > 0"
  
  composed_of :search,
              :class_name => 'EntrySearch',
              :mapping => %w(search_conditions to_json),
              :constructor => EntrySearch.method(:from_json),
              :converter   => EntrySearch.method(:from_json)
  before_create :populate_title_based_on_search_summary
  
  def title
    self['title'] || search.summary
  end
  
  def search_conditions
    JSON.parse(self['search_conditions'])
  end
  
  def populate_title_based_on_search_summary
    self.title = search.summary
  end
end
