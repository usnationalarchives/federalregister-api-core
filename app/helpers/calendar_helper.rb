module CalendarHelper
  def calendar_view(entry, options = {})
    options.symbolize_keys!
    
    type = options[:type] || :tri
    context = options[:context] || :future
    
    year = entry.publication_date.year
    start_month = entry.publication_date.month
    months = [start_month]
    
    if type == :tri
      if context == :context
        months = [start_month - 1, start_month, start_month + 1]
      elsif context == :future
        months = [start_month, start_month + 1, start_month + 2]
      end
    end
    
    date_range = find_date_range(months)
    
    html = ''
    months.each do |month|
      html << calendar_for(year, month, &entry_events_proc(entry, date_range))
    end
    html 
  end
  
  def dates_calendar_view(dates, year, month)
    calendar_for(year, month, &dates_events_proc(dates))
  end
  
  def entry_events_proc(entry, date_range)
    events = ReferencedDate.find(:all, :select => 'date', :conditions => {:entry_id => entry.id, :date => date_range[0]..date_range[1]} )
    events = events.map{|e| e.date}
    lambda do |day|
      if events.include?(day)
        [link_to(day.day, entry_path(entry)), { :class => "dayWithEvents" }]
      else
        day.day
      end
    end
  end
  
  def dates_events_proc(dates)
    events = dates.map{|e| e.date}
    lambda do |day|
      if events.include?(day)
        [link_to(day.day, "#event_#{day.to_s(:db)}"), { :class => "dayWithEvents" }]
      else
        day.day
      end
    end
  end
  
  def find_date_range(months)
    year = Time.now.strftime('%Y').to_i
    if months.length > 1
      date_range = [Date.new(year, months[0], 1), Date.new(year, months[2], -1)]
    else
      date_range = [Date.new(year, months[0], 1), Date.new(year, months[0], -1)]
    end
    date_range
  end
end