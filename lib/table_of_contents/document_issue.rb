class TableOfContents::DocumentIssue < TableOfContentsTransformer

  def initialize(date)
    super
  end

  def self.perform(date)
    new(date).save_standard_toc
  end

  def standard_toc
    agency_hash(agencies_standard, entries_without_agencies_standard)
  end

  def issue
    @issue ||= Issue.completed.find_by_publication_date!(date)
  end

  def toc
    @toc ||= TableOfContentsPresenter.new(issue.entries.scoped(:include => [:agencies, :agency_names]))
  end

  def agencies_standard
    toc.agencies
  end

  def entries_without_agencies_standard
    toc.entries_without_agencies
  end

  def save_standard_toc
    save_file(standard_toc_output_path, "#{date.strftime('%d')}.json", standard_toc.to_json)
  end

  private

  def standard_toc_output_path
    "data/document_issues/json/#{date.to_s(:year_month)}/"
  end

end