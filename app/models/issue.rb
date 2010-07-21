class Issue
  attr_accessor :publication_date
  def initialize(publication_date)
    case publication_date
    when String
      @publication_date = Date.parse(publication_date)
    else
      @publication_date = publication_date
    end
  end
  
  def self.current
    new(IssueApproval.latest_publication_date)
  end
  
  def self.most_recent(n)
    dates = Entry.find_as_array(
      :select => "distinct(publication_date) AS publication_date",
      :order => "publication_date DESC",
      :limit => 50
    )
    dates.map{|date| new(date) }
  end
  
  def entries
    Entry.published_on(@publication_date)
  end
  
  def notice_count
    entries.of_type('NOTICE').count
  end
  
  def proposed_rule_count
    entries.of_type('PRORULE').count
  end
  
  def rule_count
    entries.of_type('RULE').count
  end
  
  def presidential_documents_count
    entries.of_type('PRESDOCU').count
  end
  
  def significant_entries_count
    entries.significant.count
  end
  
  def total_pages
    entries.maximum(:end_page) - entries.minimum(:start_page) + 1
  end
  
  def public_meeting_count
    Event.public_meeting.count(:joins => :entry, :conditions => {:entries => {:publication_date => publication_date}})
  end
  
  def eventful_entries
    eventful_entries_search.results
  end
  
  def eventful_entries_count
    eventful_entries_search.results.size
  end
  
  private
  
  def eventful_entries_search
    EntrySearch.new(
      :conditions => {
        :term => "(#{Event::PUBLIC_MEETING_PHRASES.map{|phrase| "\"#{phrase}\""}.join('|')})",
        :date => publication_date.to_s
      },
      :per_page => 200
    )
  end
end