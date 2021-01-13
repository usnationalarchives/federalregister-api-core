class IssueReportMonthlyPresenter
  attr_reader :year, :date_range_type

  def initialize(year:, date_range_type:)
    @year = year
    @date_range_type = date_range_type
  end

  def date_range
    if date_range_type == "fy"
       (Date.new(year, 10, 1) - 1.year) .. Date.new(year, 9, 30)
     else
       Date.new(year, 1, 1) .. Date.new(year, 12, 31)
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
      group("YEAR(publication_date), QUARTER(publication_date), MONTH(publication_date) WITH ROLLUP").
      to_sql
    
    results.map do |quarter, month, *remaining|
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
      rows << [summary, *remaining] unless date_range_type == "fy" && month.nil? && quarter.nil? && results.last != [quarter, month, *remaining]
    end
    rows
  end
end