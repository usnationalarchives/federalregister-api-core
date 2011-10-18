# == Schema Information
#
# Table name: mailing_lists
#
#  id                         :integer(4)      not null, primary key
#  search_conditions          :text
#  title                      :string(255)
#  active_subscriptions_count :integer(4)      default(0)
#  created_at                 :datetime
#  updated_at                 :datetime
#  type                       :string(255)
#

class MailingList < ApplicationModel
  has_many :subscriptions
  has_many :active_subscriptions,
           :class_name => "Subscription",
           :conditions => "subscriptions.confirmed_at IS NOT NULL and subscriptions.unsubscribed_at IS NULL"
  named_scope :active,
              :conditions => "active_subscriptions_count > 0"
  named_scope :for_entries,
              :conditions => {:search_type => 'Entry'}
  named_scope :for_public_inspection_documents,
              :conditions => {:search_type => 'PublicInspectionDocument'}

  before_create :populate_title_based_on_search_summary
  
  def self.find_by_search(search)
    find_by_search_conditions_and_type(search.to_json, "MailingList::#{search.model}")
  end

  def search
    @search ||= self[:search_conditions].present? ? search_class.new(:conditions => search_conditions) : nil
  end
  
  def search=(search)
    @search = search
    self.search_conditions = search.to_json
    self.type = "MailingList::#{@search.model.name}"
    search
  end
  
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
