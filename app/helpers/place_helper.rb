module PlaceHelper
  def entry_list(place)
    list = []
    place.entries.each do |entry|
      list << link_to(entry.title, entry_path(entry) )
    end
    list.join(', ')
  end
end