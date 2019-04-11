class TableOfContentsTransformer::DocumentIssue < TableOfContentsTransformer
  def issue
    @issue ||= Issue.completed.find_by_publication_date!(date)
  end

  def toc_presenter
    @toc_presenter ||= TableOfContentsPresenter.new(
      issue.entries.scoped(:include => [:agencies, :agency_names])
    )
  end

  private

  def json_toc_dir
    path_manager.document_issue_json_toc_dir
  end

  def json_path
    path_manager.document_issue_json_toc_path
  end
end
