class MailingList::PublicInspectionDocument < MailingList
  def search_class
    PublicInspectionDocumentSearch
  end

  def deliver!(document_ids, options = {})
    results = search.results_for_date(date, :select => "id, title, publication_date, document_number, granule_class, document_file_path, abstract, start_page, end_page, toc_doc, toc_subject")
    
    unless results.empty?
      subscriptions = active_subscriptions
      subscriptions = subscriptions.not_delivered_on(date) unless options[:force_delivery]
      
      subscriptions.find_in_batches(:batch_size => 1000) do |batch_subscriptions|
        Mailer.deliver_mailing_list(self, results, batch_subscriptions)
      end
      subscriptions.update_all(['delivery_count = delivery_count + 1, last_delivered_at = ?, last_issue_delivered = ?', Time.now, date])
      Rails.logger.info("delivered mailing_lists/#{id} to #{subscriptions.count} subscribers (#{results.size} articles})")
    end
  end
end
