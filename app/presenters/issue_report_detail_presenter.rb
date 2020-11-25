class IssueReportDetailPresenter
  attr_reader :year
  def initialize(year:)
    @year = year
  end

  def as_csv
    date_range = Date.new(year, 1, 1) .. Date.new(year, 12, 31)
    CSV.generate do |csv|
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

      Issue.where(publication_date: date_range).order(publication_date: "asc").each do |issue|
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
  end
end