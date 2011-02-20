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
    begin
      client = Content::RegulationsDotGov::Client.new
      documents = client.search("\"#{document_number}\"")
    
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
  memoize :regulationsdotgov_document
end