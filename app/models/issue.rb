class Issue < ApplicationModel
  has_many :entries,
           :primary_key => :publication_date,
           :foreign_key => :publication_date

  has_many :reprocessed_issues
  has_many :issue_parts, dependent: :destroy

  def self.completed
    scoped(:conditions => "completed_at IS NOT NULL")
  end

  def self.approved
    find_by_publication_date(IssueApproval.latest_publication_date)
  end

  def self.current
    Issue.completed.order("publication_date").last
  end

  def self.most_recent(n = 50)
    scoped(:order => "publication_date DESC", :limit => n).completed
  end

  def self.last_issue_date_in_year(year)
    scoped(:conditions => {:publication_date => Date.new(year.to_i,1,1)..Date.new(year.to_i,12,31)}).
      completed.
      maximum(:publication_date)
  end

  def self.complete?(date)
    issue = find_by_publication_date(date)
    issue.try(:complete?) || false
  end

  def self.current_issue_is_late?(time="9AM")
    !Issue.completed.find_by_publication_date(Time.current.to_date) &&
    (Time.current > Time.zone.parse(time)) &&
    should_have_an_issue?(Time.current.to_date)
  end

  def self.should_have_an_issue?(date)
    !(date.wday == 0 || date.wday == 6 || Holiday.find_by_date(date))
  end

  def self.bulk_data_missing?(date)
    url = Content::EntryImporter::BulkdataFile.new(date).url
    response = Faraday.new(url: url).head
    !response.success?
  end

  def self.mods_missing?(date)
    url = Content::EntryImporter::ModsFile.new(date).url
    response = Faraday.new(url: url).head
    !response.success?
  end

  def self.next_date_to_import
    date = Date.current

    while(true) do
      if should_have_an_issue?(date)
        return date
      else
        date = date + 1
      end
    end
  end

  def to_param
    publication_date.to_s(:db)
  end

  def complete?
    completed_at.present?
  end

  def complete!
    unless complete?
      self.completed_at = Time.now
      save!
    end
  end

  def page_count
    end_page - start_page + 1
  end

  def notice_count
    read_attribute(:notice_count) || entries.of_type('NOTICE').count
  end

  def proposed_rule_count
    read_attribute(:proposed_rule_count) || entries.of_type('PRORULE').count
  end

  def rule_count
    read_attribute(:rule_count) || entries.of_type('RULE').count
  end

  def presidential_documents_count
    read_attribute(:presidential_documents_count) || entries.of_type('PRESDOCU').count
  end

  def significant_entries_count
    Entry.search_klass.new(:conditions => {:publication_date => {:is => publication_date}, :significant => '1'}).count
  end

  def unknown_document_count
    read_attribute(:unknown_document_count) || entries.where.not(granule_class: ['NOTICE', 'PRORULE', 'RULE', 'PRESDOCU']).count
  end

  def total_pages
    end_page = entries.maximum(:end_page)
    start_page = entries.minimum(:start_page)
    if end_page && start_page
      end_page - start_page + 1
    else
      nil
    end
  end

  def eventful_entries
    eventful_entries_search.results
  end

  def eventful_entries_count
    eventful_entries_search.results.size
  end

  def year
    publication_date.year
  end

  def next
    Issue.
      where("publication_date > ?", publication_date).
      order("publication_date").
      first
  end

  def previous
    Issue.
      where("publication_date < ?", publication_date).
      order("publication_date DESC").
      first
  end

  private

  validate :toc_note_active do
    errors.add(:base, 'Title must be a present if TOC Note is active') if toc_note_active? && toc_note_title.blank?
    errors.add(:base, 'Note must be a present if TOC Note is active') if toc_note_active? && toc_note_text.blank?
  end

  def eventful_entries_search
    Entry.search_klass.new(
      :conditions => {
        :term => "(#{Event::PUBLIC_MEETING_PHRASES.map{|phrase| "\"#{phrase}\""}.join('|')})",
        :publication_date => {:is => publication_date.to_s}
      },
      :per_page => 200
    )
  end
end
