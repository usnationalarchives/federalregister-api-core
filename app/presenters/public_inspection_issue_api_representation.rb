class PublicInspectionIssueApiRepresentation
  def self.daily_facet(conditions)
    issues = PublicInspectionIssue.published_between(
      conditions[:publication_date][:gte],
      conditions[:publication_date][:lte] || Date.today
    )

    representation_for(issues)
  end

  private

  def self.representation_for(issues)
    issues.inject({}) do |hsh, issue|
      hsh[issue.publication_date.to_s(:iso)] = {
        :special_filings => {
          :last_updated_at => issue.special_filings_updated_at,
          :documents => issue.special_filing_documents.count,
          :agencies => issue.special_filing_agencies.count
        },
        :regular_filings => {
          :last_updated_at => issue.regular_filings_updated_at,
          :documents => issue.regular_filing_documents.count,
          :agencies => issue.regular_filing_agencies.count
        }
      }
      hsh
    end
  end
end

