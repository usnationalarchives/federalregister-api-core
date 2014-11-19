module Content::EntryImporter::RegulationsDotGovAttributes
  extend Content::EntryImporter::Utils
  extend ActiveSupport::Memoizable
  provides :checked_regulationsdotgov_at, :regulationsdotgov_url, :comment_url, :regulations_dot_gov_comments_close_on, :regulations_dot_gov_docket_id
  
  def checked_regulationsdotgov_at
    Time.now
  end
  
  def regulationsdotgov_url
    regulationsdotgov_document.try(:url)
  end
  
  def comment_url
    regulationsdotgov_document.try(:comment_url)
  end

  def regulations_dot_gov_comments_close_on
    regulationsdotgov_document.try(:comment_due_date)
  end

  def regulations_dot_gov_docket_id
    regulationsdotgov_document.try(:docket_id)
  end
  
  private
  
  def regulationsdotgov_document
    begin
      RegulationsDotGov::Client.new.find_by_document_number(entry.document_number)
    rescue RegulationsDotGov::Client::ResponseError
      nil
    end
  end
  memoize :regulationsdotgov_document
end
