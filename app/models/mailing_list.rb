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
  has_many :subscriptions
  has_many :active_subscriptions,
           :class_name => "Subscription",
           :conditions => "subscriptions.confirmed_at IS NOT NULL and subscriptions.unsubscribed_at IS NULL"
  named_scope :active, :conditions => "active_subscriptions_count > 0"
  
  before_create :populate_title_based_on_search_summary
  
  def self.find_by_search(search)
    find_by_search_conditions(search.to_json)
  end
  
  def search
    @search ||= self[:search_conditions].present? ? EntrySearch.new(:conditions => search_conditions) : nil
  end
  
  def search=(search)
    @search = search
    self.search_conditions = search.to_json
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

  def deliver!(date, options = {})
    results = search.results_for_date(date, :select => "id, title, publication_date, document_number, granule_class, document_file_path, abstract, start_page, end_page, toc_doc, toc_subject")
    
    unless results.empty?
      subscriptions = active_subscriptions
      subscriptions = subscriptions.not_delivered_on(date) unless options[:force_delivery]
      
      # TODO: exclude non-developers from receiving emails in development mode
      # TODO: refactor to find_in_batches and use sendgrid to send to 1000 subscribers at once
      subscriptions.find_in_batches(:batch_size => 1000) do |batch_subscriptions|
        Mailer.deliver_mailing_list(self, results, batch_subscriptions)
      end
      subscriptions.update_all(['delivery_count = delivery_count + 1, last_delivered_at = ?, last_issue_delivered = ?', Time.now, date])
      Rails.logger.info("delivered mailing_lists/#{id} to #{subscriptions.count} subscribers (#{results.size} articles})")
    end
  end
end
