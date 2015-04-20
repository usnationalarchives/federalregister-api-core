class PublicInspectionTableOfContentsTransformer < TableOfContentsTransformer
  def self.perform(date)
    new(date).save(table_of_contents)
  end

  def table_of_contents
    agency_hash(agencies, entries_without_agencies)
  end

  def issue
    @issue ||= PublicInspectionIssue.published.find_by_publication_date!(date)
  end

  def agencies
    toc.agencies
  end

  def entries_without_agencies
    toc.entries_without_agencies
  end

  private

  def json_toc_dir
    "data/public_inspection_issues/json/#{date.to_s(:year_month)}/#{date.strftime('%d')}"
  end
end
