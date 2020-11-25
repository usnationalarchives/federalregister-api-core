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

  def self.yearly_report(year=Date.today.strftime("%Y"))
    return "Invald Date" unless year.scan(/\D/).empty? && (1582..2500).include?(year.to_i)
    start_of_year = (year + "-01-01").to_date
    end_of_year = (year + "-12-31").to_date
    dates = (start_of_year..end_of_year.to_date).map{ |date| date.strftime("%F") }
    all_issues = Issue.where(publication_date: dates).order(publication_date: "asc")
    report_name = "./tmp/issue-monthly-report-#{year.to_s}.csv"

    fields_array = [:presidential_document_count, :rule_count, :proposed_rule_count, :notice_count, :unknown_document_count, :frontmatter_page_count, :backmatter_page_count, :correction_count, :presidential_document_page_count, 
:rule_page_count, :proposed_rule_page_count, :notice_page_count, :unknown_document_page_count, :blank_page_count, :total_number_of_pages_minus_skips, :correction_page_count]

    CSV.open(report_name, "wb") do |csv|
      csv << [nil, nil, "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
      month_total = [nil, "Total Number of Issues"]

      (1..12).each do |month|
        month_start_date = (year + "-" + month.to_s + "-01").to_date
        month_end_date = month_start_date.end_of_month
        month_dates = (month_start_date..month_end_date.to_date).map{ |date| date.strftime("%F") }
        month_total << Issue.where(publication_date: month_dates).order(publication_date: "asc").count
      end

      csv << month_total
      csv << []

			monthly_totals_hash = Hash.new
			(1..12).each do |month|
				monthly_start_date = (year + "-" + month.to_s + "-01").to_date
				monthly_dates = (monthly_start_date..monthly_start_date.end_of_month).map{ |date| date.strftime("%F") }.to_a

				monthly_totals_hash[month] = Hash.new
				monthly_totals_hash[month][:presidential_document_count] = all_issues.select{ |x| monthly_dates.include?(x.publication_date.strftime("%F")) }.map{ |y| y.presidential_document_count.to_i }.reduce(:+).to_i
				monthly_totals_hash[month][:rule_count] = all_issues.select{ |x| monthly_dates.include?(x.publication_date.strftime("%F")) }.map{ |y| y.rule_count.to_i }.reduce(:+).to_i
				monthly_totals_hash[month][:proposed_rule_count] = all_issues.select{ |x| monthly_dates.include?(x.publication_date.strftime("%F")) }.map{ |y| y.proposed_rule_count.to_i }.reduce(:+).to_i
				monthly_totals_hash[month][:notice_count] = all_issues.select{ |x| monthly_dates.include?(x.publication_date.strftime("%F")) }.map{ |y| y.notice_count.to_i }.reduce(:+).to_i
				monthly_totals_hash[month][:unknown_document_count] = all_issues.select{ |x| monthly_dates.include?(x.publication_date.strftime("%F")) }.map{ |y| y.unknown_document_count.to_i }.reduce(:+).to_i
				monthly_totals_hash[month][:frontmatter_page_count] = all_issues.select{ |x| monthly_dates.include?(x.publication_date.strftime("%F")) }.map{ |y| y.frontmatter_page_count.to_i }.reduce(:+).to_i
				monthly_totals_hash[month][:backmatter_page_count] = all_issues.select{ |x| monthly_dates.include?(x.publication_date.strftime("%F")) }.map{ |y| y.backmatter_page_count.to_i }.reduce(:+).to_i
				monthly_totals_hash[month][:correction_count] = all_issues.select{ |x| monthly_dates.include?(x.publication_date.strftime("%F")) }.map{ |y| y.correction_count.to_i }.reduce(:+).to_i

				monthly_totals_hash[month][:presidential_document_page_count] = all_issues.select{ |x| monthly_dates.include?(x.publication_date.strftime("%F")) }.map{ |y| y.presidential_document_page_count.to_i }.reduce(:+).to_i
				monthly_totals_hash[month][:rule_page_count] = all_issues.select{ |x| monthly_dates.include?(x.publication_date.strftime("%F")) }.map{ |y| y.rule_page_count.to_i }.reduce(:+).to_i
				monthly_totals_hash[month][:proposed_rule_page_count] = all_issues.select{ |x| monthly_dates.include?(x.publication_date.strftime("%F")) }.map{ |y| y.proposed_rule_page_count.to_i }.reduce(:+).to_i
				monthly_totals_hash[month][:notice_page_count] = all_issues.select{ |x| monthly_dates.include?(x.publication_date.strftime("%F")) }.map{ |y| y.notice_page_count.to_i }.reduce(:+).to_i
				monthly_totals_hash[month][:unknown_document_page_count] = all_issues.select{ |x| monthly_dates.include?(x.publication_date.strftime("%F")) }.map{ |y| y.unknown_document_page_count.to_i }.reduce(:+).to_i
				monthly_totals_hash[month][:blank_page_count] = all_issues.select{ |x| monthly_dates.include?(x.publication_date.strftime("%F")) }.map{ |y| y.blank_page_count.to_i }.reduce(:+).to_i
				monthly_totals_hash[month][:total_number_of_pages] = monthly_totals_hash[month][:presidential_document_page_count] +
																														 monthly_totals_hash[month][:rule_page_count] +
																														 monthly_totals_hash[month][:proposed_rule_page_count] +
																														 monthly_totals_hash[month][:notice_page_count] +
																														 monthly_totals_hash[month][:unknown_document_page_count] +
																														 monthly_totals_hash[month][:blank_page_count]
				monthly_totals_hash[month][:total_number_of_pages_minus_skips] = monthly_totals_hash[month][:total_number_of_pages] - monthly_totals_hash[month][:blank_page_count]
				monthly_totals_hash[month][:correction_page_count] = all_issues.select{ |x| monthly_dates.include?(x.publication_date.strftime("%F")) }.map{ |y| y.correction_page_count.to_i }.reduce(:+).to_i
			end

			fields_array.each do |field|
				test = []
				(1..12).each do |month|
					test << monthly_totals_hash[month][field]
				end

        if field == :presidential_document_count
				  csv << ["Page Counts", "Presidential Documents"] + test
        elsif field == :presidential_document_page_count
				  csv << ["Document Counts", "Presidential Documents"] + test
        elsif field == :rule_count
				  csv << [nil, "Rules"] + test
        else
          csv << [nil, nil] + test
        end
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
