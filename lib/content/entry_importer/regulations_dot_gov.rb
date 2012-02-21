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
    Content::RegulationsDotGov.new(ENV['regulations_dot_gov_api_key']).find_by_document_number(entry.document_number)
  end
  memoize :regulationsdotgov_document
end
