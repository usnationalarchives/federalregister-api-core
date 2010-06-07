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
  
  def agency_names(entry)
    if entry.agencies.present?
      agencies = entry.agencies_excluding_parents.map{|a| "the #{link_to a.name, agency_path(a)}" }
    else
      agencies = entry.agency_names.map(&:name)
    end
    agencies.to_sentence
  end
  
  def issue_pdf_url(date)
    "http://www.gpo.gov/fdsys/pkg/FR-#{date.to_s(:to_s)}/pdf/FR-#{date.to_s(:to_s)}.pdf"
  end
end