module PathHelper
  def entry_path(entry)
    "/entries/#{entry.publication_date.strftime('%Y')}/#{entry.publication_date.strftime('%m')}/#{entry.publication_date.strftime('%d')}/#{entry.document_number}/#{entry.slug}"
  end
  
  def calendar_by_ymd_path(date)
    "/calendar/#{date.date.to_formatted_s(:ymd)}/"
  end
  
  def citation_path(entry)
    citation = entry.citation.split(' ')
    "/citation/#{citation.first}/#{citation.last}"
  end
end