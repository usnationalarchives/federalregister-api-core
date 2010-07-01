class Issue
  attr_accessor :publication_date
  def initialize(publication_date)
    @publication_date = publication_date
  end
  
  def self.current
    new(IssueApproval.latest_publication_date)
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
end