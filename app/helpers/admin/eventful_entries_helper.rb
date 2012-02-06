module Admin::EventfulEntriesHelper
  def link_events(text, dates)
    result = text.dup
    
    dates.uniq.each do |date|
      result.gsub!(date) do |date_str|
        date = Date.parse(date_str)
        if date
          link_to date_str, '#', :class => "date", 'data-date' => date.to_s
        else
          date_str
        end
      end
    end
    
    result
  end
  
  # def link_places(text, places)
  #   result = text.dup
  #   places.each do |place|
  #     result.gsub!(/#{Regexp.escape(place.string)}/) do |place_str|
  #       link_to place.string, '#', :class => "place", 'data-id' => place.id, 'data-name' => place.name
  #     end
  #   end
  #   result
  # end
  
  def link_places(text, places)
    result = text.dup
    places.sort_by{|p| p.string.length }.reverse.each do |place|
      result = modify_text_not_inside_anchor(result) do |text|
        text.gsub(/#{Regexp.escape(place.string)}/) do |place_str|
          link_to place.string, '#',
            :class => "place",
            'data-id' => place.id,
            'data-string' => place.string,
            'data-name' => place.name,
            'data-type' => place.type,
            'data-longitude' => place.longitude,
            'data-latitude' => place.latitude
        end
      end
    end
    result
  end
  
end
