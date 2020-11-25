class IssueReportMonthlyPresenter
  attr_reader :year
  def initialize(year:)
    @year = year
  end

  def as_csv
    date_range = Date.new(year, 1, 1) .. Date.new(year, 12, 31)
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

    date_range = Date.new(year, 1, 1) .. Date.new(year, 12, 31)
    results = Issue.connection.select_rows Issue.
      where(publication_date: date_range).
      select(
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
        "SUM(correction_count)"
      ).
      group("QUARTER(publication_date), MONTH(publication_date) WITH ROLLUP").
      to_sql
    
    rows += results.map do |quarter, month, *remaining|
      summary = if month.nil?
        if quarter.nil?
          year
        else
          "Q#{quarter}"
        end
      else
        Date.new(year,month,1).strftime("%B")
      end
      [summary, *remaining]
    end
    rows
  end
end