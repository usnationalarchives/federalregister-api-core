module PathHelper
  def entry_path(entry)
"/entries/#{entry.publication_date.strftime('%Y')}/#{entry.publication_date.strftime('%m')}/#{entry.publication_date.strftime('%d')}/#{entry.document_number}/#{entry.slug}"
  end
  
  def entry_url(entry)
    path_to_url(entry_path(entry))
  end
  
  def calendar_by_ymd_path(date)
    "/calendar/#{date.date.to_formatted_s(:ymd)}/"
  end
  
  private
  
  def path_to_url(path)
    'http://' + controller.request.host + path
  end
end