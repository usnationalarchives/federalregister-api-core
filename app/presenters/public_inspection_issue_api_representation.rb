class PublicInspectionIssueApiRepresentation
  def self.daily_facet(conditions)
    issues = PublicInspectionIssue.published_between(
      conditions[:publication_date][:gte],
      conditions[:publication_date][:lte] || Date.today
    )

    date_representation_for(issues)
  end

  def self.type_facet(conditions)
    issue = PublicInspectionIssue.find_by_publication_date(
      conditions[:publication_date][:is]
    )

    type_representation_for(issue)
  end

  private

  def self.date_representation_for(issues)
    issues.inject({}) do |hsh, issue|
      hsh[issue.publication_date.to_s(:iso)] = {
        :special_filings => {
          :last_updated_at => issue.special_filings_updated_at,
          :documents => issue.special_filing_documents_count,
          :agencies => issue.special_filing_agencies_count
        },
        :regular_filings => {
          :last_updated_at => issue.regular_filings_updated_at,
          :documents => issue.regular_filing_documents_count,
          :agencies => issue.regular_filing_agencies_count
        }
      }
      hsh
    end
  end

  def self.type_representation_for(issue)
    hsh = {}
    return hsh unless issue

    hsh[issue.publication_date.to_s(:iso)] = {
      :special_filings => issue.special_filing_documents.group_by(&:granule_class).inject({}) do |types, groupings|
        types[groupings[0]] = {
          :count => groupings[1].size,
          :name => groupings[1].first.entry_type
        }
        types
      end,
      :regular_filings => issue.regular_filing_documents.group_by(&:granule_class).inject({}) do |types, groupings|
        types[groupings[0]] = {
          :count => groupings[1].size,
          :name => groupings[1].first.entry_type
        }
        types
      end
    }
    hsh
  end
end

