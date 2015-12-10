module EntryHelper
  def entry_title(entry)
    truncate_words(entry.title, :length => 100)
  end
  
  def agency_names(entry, options = {})
    autolink = true unless options[:no_links]
    if entry.agencies.present?
      agencies = entry.agencies.excluding_parents.map{|a| "the #{link_to_if autolink, a.name, agency_path(a)}" }
    else
      agencies = entry.agency_names.map(&:name)
    end
    agencies.to_sentence
  end
  
  def entry_page_range(entry)
    if entry.end_page == entry.start_page
      "Page #{entry.start_page}"
    else
      "Pages #{entry.start_page} - #{entry.end_page}"
    end
  end
  
  def issue_pdf_url(date)
    "https://www.gpo.gov/fdsys/pkg/FR-#{date.to_s(:to_s)}/pdf/FR-#{date.to_s(:to_s)}.pdf"
  end
  
  def days_remaining(date)
    num_days = date - Time.current.to_date
    if num_days > 0
      "in " + pluralize(num_days, 'day')
    else
      'today'
    end
  end
end
