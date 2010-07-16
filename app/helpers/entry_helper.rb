module EntryHelper
  def entry_title(entry)
    truncate_words(entry.title, :length => 100)
  end
  
  def agency_names(entry)
    if entry.agencies.present?
      agencies = entry.agencies.excluding_parents.map{|a| "the #{link_to a.name, agency_path(a)}" }
    else
      agencies = entry.agency_names.map(&:name)
    end
    agencies.to_sentence
  end
  
  def issue_pdf_url(date)
    "http://www.gpo.gov/fdsys/pkg/FR-#{date.to_s(:to_s)}/pdf/FR-#{date.to_s(:to_s)}.pdf"
  end
  
  def days_remaining(date)
    num_days = @entry.comments_close_on - Date.today
    if num_days > 0
      "in " + pluralize(num_days, 'day')
    else
      'today'
    end
  end
end