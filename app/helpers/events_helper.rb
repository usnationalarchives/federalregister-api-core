module EventsHelper
  def add_google_event_url(event)
    "http://www.google.com/calendar/render?action=TEMPLATE&text=#{CGI::escape(event_title(event))}&dates=#{event.date.to_s(:ymd_no_formatting)}/#{event.date.to_s(:ymd_no_formatting)}&trp=false&details=#{CGI::escape event_abstract(event)}&sf=true&output=xml"
  end
  
  def add_windows_live_event_url(event)
  "http://calendar.live.com/calendar/calendar.aspx?rru=addevent&dtstart=#{event.date.to_s(:ymd_no_formatting)}&dtend=#{event.date.to_s(:ymd_no_formatting)}&summary=#{CGI::escape event_title(event)}&description=#{CGI::escape event_abstract(event)}"
  end
  
  def add_yahoo_event_url(event)
  "http://calendar.yahoo.com/?V=60&TITLE=#{CGI::escape event_title(event)}&TYPE=10&ST=#{event.date.to_s(:ymd_no_formatting)}&DESC=#{CGI::escape event_abstract(event)}"
  end
  
  def event_title(event)
    "#{event.type}: #{event.title}"
  end
  
  def event_abstract(event)
    truncate_words(event.entry.try(:abstract), :length => 250) || ''
  end
end