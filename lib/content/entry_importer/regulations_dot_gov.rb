module Content::EntryImporter::RegulationsDotGov
  extend Content::EntryImporter::Utils
  extend ActiveSupport::Memoizable
  provides :checked_regulationsdotgov_at, :regulationsdotgov_url, :comment_url
  
  def checked_regulationsdotgov_at
    Time.now
  end
  
  def regulationsdotgov_url
    regulationsdotgov_document.try(:url)
  end
  
  def comment_url
    regulationsdotgov_document.try(:comment_url)
  end
  
  private
  
  def regulationsdotgov_document
    return nil unless @entry.comments_close_on && @entry.comments_close_on >= Date.current
    possible_regulationsdotgov_search_terms.each do |term|
      doc = find_single_document(term)
      return doc if doc
    end
    
    nil
  end
  memoize :regulationsdotgov_document
  
  def possible_regulationsdotgov_search_terms
    terms = ["\"#{@entry.document_number}\""]
    
    @entry.docket_numbers.each do |docket_number|
      terms << "\"#{@entry.document_number}\" \"#{docket_number.number}\""
    end

    terms << "\"#{@entry.document_number}\" \"#{entry.title}\""

    @entry.agency_names.each do |agency_name|
      terms << "\"#{@entry.document_number}\" \"#{agency_name.name}\""
    end
    
    @entry.regulation_id_numbers.each do |rin|
      terms << "\"#{@entry.document_number}\" \"#{rin}\""
    end
    
    terms
  end
  
  def find_single_document(search_term)
    begin
      client = Content::RegulationsDotGov::Client.new
      documents = client.search(search_term)
    
      if documents.size == 1
        documents.first
      else
        nil
      end
    rescue Exception => e
      Rails.logger.warn e
      HoptoadNotifier.notify(e)
      return nil
    end
  end
end
