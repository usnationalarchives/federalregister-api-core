module PathHelper
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