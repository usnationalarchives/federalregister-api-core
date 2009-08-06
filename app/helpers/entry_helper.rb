module EntryHelper
  def display_agencies_for_entry(entry)
    if entry.agency
      agencies = []
      unless entry.agency_id.nil? || entry.agency.parent_id.nil?
        agencies << link_to(entry.agency.parent.name, agency_path(entry.agency.parent) )
      end
      agencies << link_to(entry.agency.name, agency_path(entry.agency) )
      agencies.join(' :: ')
    end
  end
  
  def text_with_links(entry, text)
    text = add_date_links(entry, text)
    text = add_citation_links(text)
    text
  end
end