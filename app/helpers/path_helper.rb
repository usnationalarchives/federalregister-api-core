module PathHelper
  def entry_path(entry)
    "/entries/#{entry.publication_date.strftime('%Y')}/#{entry.publication_date.strftime('%m')}/#{entry.publication_date.strftime('%d')}/#{entry.document_number}/#{entry.slug}"
  end
  
  def entry_url(entry)
    path_to_url(entry_path(entry))
  end
  
  def short_entry_path(entry)
    "/e/#{entry.document_number}"
  end
  
  def short_entry_url(entry)
    path_to_url(short_entry_path(entry))
  end
  
  def calendar_by_ymd_path(date)
    "/calendar/#{date.date.to_formatted_s(:ymd)}/"
  end
  
  def events_path(date)
    if date.class == Date
      "/events/#{date.to_formatted_s(:year_month)}/"      
    else
      "/events/#{date.date.to_formatted_s(:year_month)}/"
    end
  end
  
  def citation_path(entry)
    citation = entry.citation.split(' ')
    "/citation/#{citation.first}/#{citation.last}"
  end
  
  def locations_path(place)
    "/locations/#{place.slug}/#{place.id}"
  end
  
  def entries_by_date_path(date, options={})
    path_params = ''
    options.each_with_index do |option, index|
      path_params += "#{option[0]}=#{option[1]}"
      path_params += index != (options.size - 1) ? '&' : ''
    end
    path = "/entries/#{date.year}/#{sprintf "%02d", date.month}/#{sprintf "%02d", date.day}"
    if !path_params.empty?
      path += "?#{path_params}"
    end
    path
  end
  
  def entries_exploration_path
    "/entries/explore"
  end
  
  def topic_group_path(group_name, options = {})
    clean_group_name = group_name.sub(/ /, '-')
    path = "/topics/#{clean_group_name}"
    if options[:format]
      path += '.' + options[:format].to_s
    end
    
    path
  end
  
  private
  
  def path_to_url(path)
    'http://' + controller.request.host + path
  end
end