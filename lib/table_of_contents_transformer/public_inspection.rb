class TableOfContentsTransformer::PublicInspection < TableOfContentsTransformer
  def issue
    @issue ||= PublicInspectionIssue.published.find_by_publication_date!(date)
  end

  private

  def json_toc_dir
    "data/public_inspection_issues/json/#{date.to_s(:year_month)}/#{date.strftime('%d')}"
  end
end
