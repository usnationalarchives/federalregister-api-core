module Admin::EventfulEntriesHelper
  def link_events(text, events)
    result = text.dup
    
    events.each do |event|
      result.gsub!(event, "<strong>#{event}</strong>")
    end
    
    result
  end
end