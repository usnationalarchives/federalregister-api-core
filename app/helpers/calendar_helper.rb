module CalendarHelper
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
      html << calendar_for(date.year, date.month, :current_month => "%B %Y", :calendar_class => 'group calendar', &entries_proc(date))
    end
    html
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
  
  def entries_proc(date)
    published_dates = Entry.find_as_array(
      :select => "distinct(publication_date) AS publication_date",
      :conditions => {:publication_date => date.beginning_of_month .. date.end_of_month}
    ).map{|s| Date.parse(s) }
    
    lambda do |date|
      if published_dates.include?(date)
        [link_to(date.day, "#entry_#{date.to_s(:ymd)}"), { :class => "dayWithEntries" }]
      else
        date.day
      end
    end
  end
end