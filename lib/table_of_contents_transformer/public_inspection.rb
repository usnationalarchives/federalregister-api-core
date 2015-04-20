class TableOfContentsTransformer::PublicInspection < TableOfContentsTransformer
  def issue
    @issue ||= PublicInspectionIssue.published.find_by_publication_date!(date)
  end

  private

  def json_toc_dir
    path_manager.public_inspection_issue_json_toc_dir
  end
end
