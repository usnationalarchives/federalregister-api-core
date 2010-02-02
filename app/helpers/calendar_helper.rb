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
      html << calendar_for(year.to_i, month.to_i, &entry_events_proc(entry, date_range))
    end
    html 
  end
  
  def dates_calendar_view(dates, year, month)
    calendar_for(year.to_i, month.to_i, :calendar_class => 'group calendar', &dates_events_proc(dates))
  end
  
  def entries_calendar_view(year, month)
    year = year.to_i
    month = month.to_i
    start_date = Date.parse("#{year}-#{month}-01")
    if Entry.count(:conditions => ['publication_date >= ?', start_date.months_since(1)]) > 0
      dates = [start_date.months_ago(1), start_date, start_date.months_since(1)]
    else
      dates = [start_date.months_ago(2), start_date.months_ago(1), start_date]
    end
    
    html = ''
    dates.each do |date|
      end_of_month = date.end_of_month
      last_pub = Entry.find(:first, 
                            :conditions => ['publication_date >= ? && publication_date <= ?', 
                                            date,
                                            end_of_month
                                           ],
                            :order => 'publication_date DESC'
                           )
      html << calendar_for(date.year, date.month, :current_month => "%B %Y", :calendar_class => 'group calendar', &entries_proc(end_of_month, last_pub))
    end
    html
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
  
  def entries_proc(end_of_month, last_pub)
    # TODO: This doesn't yet handle holidays. We should show a link to a holiday date on the calendar.
    last_day = last_pub.nil? ? end_of_month : last_pub.publication_date
    lambda do |day|
      if [0,6].include?(day.wday) || day.day > last_day.day
        day.day
      else
        [link_to(day.day, "#entry_#{day.to_s(:ymd)}"), { :class => "dayWithEntries" }]
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