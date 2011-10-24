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

class MailingList::Entry < MailingList
  def search_class
    EntrySearch
  end

  def deliver!(date, options = {})
    results = search.results_for_date(date, :select => "id, title, publication_date, document_number, granule_class, document_file_path, abstract, start_page, end_page, toc_doc, toc_subject")
    
    unless results.empty?
      subscriptions = active_subscriptions
      subscriptions = subscriptions.not_delivered_on(date) unless options[:force_delivery]
      
      subscriptions.find_in_batches(:batch_size => 1000) do |batch_subscriptions|
        Mailer.deliver_entry_mailing_list(self, results, batch_subscriptions)
      end
      subscriptions.update_all(['delivery_count = delivery_count + 1, last_delivered_at = ?, last_issue_delivered = ?', Time.now, date])
      Rails.logger.info("delivered mailing_lists/#{id} to #{subscriptions.count} subscribers (#{results.size} articles})")
    end
  end
end
