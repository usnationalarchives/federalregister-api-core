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
