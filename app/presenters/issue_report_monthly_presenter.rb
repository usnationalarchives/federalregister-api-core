class IssueReportMonthlyPresenter
  attr_reader :year, :date_range_type

  def initialize(year:, date_range_type:, custom_date_range: nil)
    @year = year
    @date_range_type = date_range_type
    @date_range = custom_date_range || default_date_range
  end

  def generate_csv(data_source)
    CSV.open('data/test.csv', 'w') do |csv|
      data_source.each do |row|
        csv << row
      end
    end
  end

  def as_csv
    CSV.generate do |csv|
      columns = data
      max_length = columns.map(&:length).max
      rows = columns.map{|e| e.values_at(0...max_length)}.transpose
      rows.each do |row|
        csv << row
      end
    end
  end

  def data
    rows = []
    rows << ["Issues", nil, nil, nil, nil, "Page Counts", nil, nil, nil, nil, nil, nil, nil, nil, nil, "Document Counts"]
    rows << [
      nil,
      "Issue Count",
      "First Page",
      "Last Page",
      nil,
      "Presidential Documents",
      "Rules",
      "Proposed Rules",
      "Notices",
      "Unknowns",
      "Skips/Blanks",
      "Total Number of Pages",
      "Total Number of Pages Minus Skips./Blanks",
      "Corrections",
      nil,
      "Presidential Documents",
      "Rules",
      "Proposed Rules",
      "Notices",
      "Unknown",
      "Total Number of FR Documents",
      "Corrections"
    ]

    results = sql_results([
      "QUARTER(publication_date)",
      "MONTH(publication_date)",
      "COUNT(*)",
      "MIN(start_page)",
      "MAX(end_page)",
      "''",
      "SUM(presidential_document_page_count)",
      "SUM(rule_page_count)",
      "SUM(proposed_rule_page_count)",
      "SUM(notice_page_count)",
      "SUM(unknown_document_page_count)",
      "SUM(blank_page_count)",
      "SUM(presidential_document_page_count)+SUM(rule_page_count)+SUM(proposed_rule_page_count)+SUM(notice_page_count)+SUM(unknown_document_page_count)+SUM(blank_page_count)",
      "SUM(presidential_document_page_count)+SUM(rule_page_count)+SUM(proposed_rule_page_count)+SUM(notice_page_count)+SUM(unknown_document_page_count)",
      "SUM(correction_page_count)",
      "'' AS placeholder",
      "SUM(presidential_document_count)",
      "SUM(rule_count)",
      "SUM(proposed_rule_count)",
      "SUM(notice_count)",
      "SUM(unknown_document_count)",
      "SUM(presidential_document_count)+SUM(rule_count)+SUM(proposed_rule_count)+SUM(notice_count)+SUM(unknown_document_count)",
      "SUM(correction_count)",
    ], "YEAR(publication_date), QUARTER(publication_date), MONTH(publication_date) WITH ROLLUP")
    
    results.uniq.map do |quarter, month, *remaining|
      summary = if month.nil?
                  if quarter.nil?
                    "#{date_range_type.upcase} #{year}"
                  else
                    if date_range_type == "fy"
                      "#{year}Q#{quarter.to_i == 4 ? "1" : (quarter.to_i + 1).to_s}"
                    else
                      "#{year}Q#{quarter}"
                    end
                  end
                else
                  Date.new(year,month,1).strftime("%B")
                end

      if date_range_type == "fy"
        rows << [summary, *remaining] unless month.nil? && quarter.nil? && results.last != [quarter, month, *remaining]
      else
        rows << [summary, *remaining]
      end
    end
    rows
  end

  def document_type_count_stats
    rows = []
    rows <<  [
      "Year",
      "Presidential Documents",
      "Rules",
      "Proposed Rules",
      "Notices",
      "Unknown",
      "Corrections",
      "Total Number of FR Documents",
    ]

    historical_document_type_counts.each do |row|
      rows << row       
    end

    sql_results([
        "YEAR(publication_date)", 
        "SUM(presidential_document_count)",
        "SUM(rule_count)",
        "SUM(proposed_rule_count)",
        "SUM(notice_count)",
        "SUM(unknown_document_count)",
        "SUM(correction_count)",
        "SUM(presidential_document_count)+SUM(rule_count)+SUM(proposed_rule_count)+SUM(notice_count)+SUM(unknown_document_count)",
      ],
      "YEAR(publication_date) WITH ROLLUP"
    ).each { |row| rows << row }

    rows
  end

  def page_count_stats
    rows = []
    rows <<  [
      "Year",
      "Presidential Documents",
      "Rules",
      "Proposed Rules",
      "Notices",
      "Unknowns",
      "Corrections",
      "Skips/Blanks",
      "Total Number of Pages",
      "Total Number of Pages Minus Skips./Blanks",
    ]

    historical_page_stats.each do |row|
      rows << row       
    end

    sql_results([
      "YEAR(publication_date)", 
      "SUM(presidential_document_page_count)",
      "SUM(rule_page_count)",
      "SUM(proposed_rule_page_count)",
      "SUM(notice_page_count)",
      "SUM(unknown_document_page_count)",
      "SUM(correction_page_count)",
      "SUM(blank_page_count)",
      "SUM(presidential_document_page_count)+SUM(rule_page_count)+SUM(proposed_rule_page_count)+SUM(notice_page_count)+SUM(unknown_document_page_count)+SUM(blank_page_count)",
      "SUM(presidential_document_page_count)+SUM(rule_page_count)+SUM(proposed_rule_page_count)+SUM(notice_page_count)+SUM(unknown_document_page_count)",
      ],
      "YEAR(publication_date) WITH ROLLUP"
    ).each { |row| rows << row }

    rows
  end

  private

  attr_reader :date_range

  def historical_document_type_counts
    CSV.read('data/historical_document_type_counts.csv')
  end

  def historical_page_stats
    CSV.read('data/historical_page_counts.csv')
  end

  def sql_results(columns, grouping_sql_statement)
    Issue.connection.select_rows Issue.
      where(publication_date: date_range).
      select(*columns).
      group(grouping_sql_statement).
      to_sql
  end

  def default_date_range
    if date_range_type == "fy"
      (Date.new(year, 10, 1) - 1.year) .. Date.new(year, 9, 30)
    else
      Date.new(year, 1, 1) .. Date.new(year, 12, 31)
    end
  end

end
