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
    "data/document_issues/json/#{date.to_s(:year_month)}"
  end

  def json_path
    "#{json_toc_dir}/#{date.strftime('%d')}.json"
  end
end
