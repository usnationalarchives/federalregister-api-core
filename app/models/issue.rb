class Issue < ApplicationModel
  has_many :entries,
           :primary_key => :publication_date,
           :foreign_key => :publication_date

  has_many :reprocessed_issues
  has_many :issue_parts

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
    ! File.exists? FileSystemPathManager.new(date).document_issue_xml_path
  end

  def self.mods_missing?(date)
    ! File.exists? FileSystemPathManager.new(date).document_mods_path
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

  def self.monthly_report(date=Date.today)
    dates = (date.to_date.at_beginning_of_month..date.to_date.at_end_of_month).map{ |date| date.strftime("%F") }
    report_name = "./tmp/issue-monthly-report-#{dates.first}.csv"

    CSV.open(report_name, "wb") do |csv|
      csv << [nil, nil, nil, nil, nil, "Document Counts", nil, nil, nil, nil, nil, "Page Counts"]
      csv << [
        "Issue Number",
        "Issue Date",
        "First Page",
        "Last Page",
        "Prelim + RA",
        "President",
        "Rules",
        "Proposed Rules",
        "Notices",
        "Unknowns",
        "Corrections",
        "President",
        "Rules",
        "Proposed Rules",
        "Notices",
        "Unknowns",
        "Skip",
        "Total",
        "Total Minus Skip",
        "Corrections"
		  ]

      Issue.where(publication_date: dates).order(publication_date: "asc").each do |issue|
        entries = issue.entries

        csv << [
          issue.number,
          issue.publication_date,
          issue.start_page,
          issue.end_page,
          issue.frontmatter_page_count.to_i + issue.backmatter_page_count.to_i,
          issue.presidential_document_count.to_i,
          issue.rule_count.to_i,
          issue.proposed_rule_count.to_i,
          issue.notice_count.to_i,
          issue.unknown_document_count.to_i,
          issue.correction_count.to_i,
          issue.presidential_document_page_count.to_i,
          issue.rule_page_count.to_i,
          issue.proposed_rule_page_count.to_i,
          issue.notice_page_count.to_i,
          issue.unknown_document_page_count.to_i,
          issue.blank_page_count.to_i,
          issue.presidential_document_page_count.to_i + issue.rule_page_count.to_i + issue.proposed_rule_page_count.to_i + issue.notice_page_count.to_i + issue.blank_page_count.to_i,
          issue.presidential_document_page_count.to_i + issue.rule_page_count.to_i + issue.proposed_rule_page_count.to_i + issue.notice_page_count.to_i + issue.blank_page_count.to_i - issue.blank_page_count.to_i,
          issue.correction_page_count.to_i
        ]
      end
    end

    created_report_file = open(report_name)
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
    read_attribute(:unknown_documents_count) || entries.where.not(granule_class: ['NOTICE', 'PRORULE', 'RULE', 'PRESDOCU']).count
  end

  def entries_total_pages(entry_collection)
    array = Array.new
    entry_collection.each_with_index do |entry, index|
      if entry.granule_class == "PRESDOCU" && entry_collection.length > 1
			  # when there are two blank pages between pres docs, we count one as that is a title page
        if entry_collection.last.id != entry.id && entry_collection[index + 1].start_page - entry.end_page == 3
				  array = array + ((entry.start_page..entry.end_page).to_a << (entry.end_page + 1))
        # if entry last page is odd, AND IS NOT THE LAST ENTRY, then we add one page
				elsif entry.end_page.to_i.odd? && !array.include?(entry.start_page) && !array.include?(entry.end_page) && entry_collection.last.id != entry.id
					array = array + (entry.start_page..(entry.end_page.to_i + 1)).to_a
				else
					array = array + (entry.start_page..entry.end_page).to_a
        end
        # account for title page which is seperated by a blabk page
        array << (array.min.to_i - 2)
      else
        array = array + (entry.start_page..entry.end_page).to_a
      end
    end
    array.uniq
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
