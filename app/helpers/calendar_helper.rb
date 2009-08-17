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
    if Entry.count(:conditions => ['publication_date >= ?', "#{year}-#{month + 1}-01"]) > 0
      month_1     = month - 1
      bump_year_1 = month_1 > 0 ? (month_1 < 13 ? 0 : 1) : -1
      year_1      = year + bump_year_1
      month_1     = month_1 > 0 ? (month_1 < 13 ? month_1 : 1) : 12
      
      month_2     = month + 1
      bump_year_2 = month_2 > 0 ? (month_2 < 13 ? 0 : 1) : -1
      year_2      = year + bump_year_2
      month_2     = month_2 > 0 ? (month_2 < 13 ? month_2 : 1) : 12
      
      dates = [[year_1,month_1], [year, month], [year_2, month_2]]
    else
      #TODO Need to only show days in the next month that we have entries for. i.e. looking at July you should not see links for all of Aug
      month_1     = month - 1
      bump_year_1 = month_1 > 0 ? (month_1 < 13 ? 0 : 1) : -1
      year_1      = year + bump_year_1
      month_1     = month_1 > 0 ? (month_1 < 13 ? month_1 : 1) : 12
      
      month_2 = month_1 - 1
      year_2  = year_1
      
      dates = [[year_2, month_2], [year_1, month_1], [year, month]]
    end
    html = ''
    dates.each do |year, month|
      end_of_month = Date.parse("#{year}-#{month}-01").end_of_month
      last_pub = Entry.find(:first, 
                            :conditions => ['publication_date >= ? && publication_date <= ?', 
                                            "#{year}-#{month}-01",
                                            end_of_month
                                           ],
                            :order => 'publication_date DESC'
                           )
      html << calendar_for(year, month, :current_month => "%B %Y", :calendar_class => 'group calendar', &entries_proc(end_of_month, last_pub))
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