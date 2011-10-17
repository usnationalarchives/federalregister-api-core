class MailingList::PublicInspectionDocument < MailingList
  def search_class
    PublicInspectionDocumentSearch
  end

  def deliver!(documents, options = {})
    results = search.results(:select => "id, title, toc_subject, toc_doc, publication_date, filed_at, document_number, granule_class, num_pages, pdf_file_name, pdf_file_size", :with => {:public_inspection_document_id => documents.map(&:id)}, :per_page => 250)
    
    unless results.empty?
      subscriptions = active_subscriptions
      
      subscriptions.find_in_batches(:batch_size => 1000) do |batch_subscriptions|
        Mailer.deliver_public_inspection_document_mailing_list(self, results, batch_subscriptions)
      end
      Rails.logger.info("delivered mailing_lists/#{id} to #{subscriptions.count} subscribers (#{results.size} public inspection documents})")
    end
  end
end
