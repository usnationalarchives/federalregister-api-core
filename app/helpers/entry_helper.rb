module EntryHelper
  def text_with_links(entry, text)
    text = add_date_links(entry, text)
    text = add_location_links(entry, text)
    text = add_citation_links(text)
    text
  end
  
  def entry_title(entry)
    truncate(entry.title, :length => 100)
  end
end