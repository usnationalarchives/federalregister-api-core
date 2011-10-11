# == Schema Information
#
# Table name: subscriptions
#
#  id                   :integer(4)      not null, primary key
#  mailing_list_id      :integer(4)
#  email                :string(255)
#  requesting_ip        :string(255)
#  token                :string(255)
#  confirmed_at         :datetime
#  unsubscribed_at      :datetime
#  created_at           :datetime
#  updated_at           :datetime
#  last_delivered_at    :datetime
#  delivery_count       :integer(4)      default(0)
#  last_issue_delivered :date
#  environment          :string(255)
#

class Subscription < ApplicationModel
  attr_accessible :email, :search_conditions
  default_scope :conditions => { :environment => Rails.env }
  before_create :generate_token
  after_create :ask_for_confirmation
  before_save :update_mailing_list_active_subscriptions_count
  
  attr_accessor :search_conditions

  belongs_to :mailing_list
  
  def mailing_list_with_autobuilding
    if mailing_list_without_autobuilding.nil?
      search = EntrySearch.new(:conditions => search_conditions)
      self.mailing_list = MailingList.find_by_search(search) || MailingList.new(:search => search)
    else
      mailing_list_without_autobuilding
    end
  end
  
  alias_method_chain :mailing_list, :autobuilding
  
  validates_presence_of :email, :requesting_ip, :mailing_list, :environment
  
  def self.not_delivered_on(date)
    scoped(:conditions => ["subscriptions.last_issue_delivered IS NULL OR subscriptions.last_issue_delivered < ?", date])
  end

  def to_param
    token
  end
  
  def active?
    confirmed_at.present? && unsubscribed_at.nil?
  end
  
  def was_active?
    confirmed_at_was.present? && unsubscribed_at_was.nil?
  end
  
  def confirm!
    unless active?
      self.confirmed_at = Time.current
      self.unsubscribed_at = nil
      self.save!
    end
  end

  def unsubscribe!
    unless self.unsubscribed_at
      self.unsubscribed_at = Time.current
      self.save!
    end
    Mailer.deliver_unsubscribe_notice(self)
  end

  private
  
  def ask_for_confirmation
    Mailer.deliver_subscription_confirmation(self)
  end
  
  def generate_token
    self.token = SecureRandom.hex(20)
  end
  
  def update_mailing_list_active_subscriptions_count
    if was_active? && ! active?
      MailingList.decrement_counter(:active_subscriptions_count, mailing_list_id)
    elsif !was_active? && active?
      MailingList.increment_counter(:active_subscriptions_count, mailing_list_id)
    end
    
    true
  end
end
