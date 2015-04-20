class TableOfContents::DocumentIssue < TableOfContentsTransformer
  def self.perform(date)
    new(date).save(table_of_contents)
  end

  def table_of_contents
    agency_hash(agencies, entries_without_agencies)
  end

  def issue
    @issue ||= Issue.completed.find_by_publication_date!(date)
  end

  def toc
    @toc ||= TableOfContentsPresenter.new(
      issue.entries.scoped(:include => [:agencies, :agency_names])
    )
  end

  def agencies
    toc.agencies
  end

  def entries_without_agencies
    toc.entries_without_agencies
  end
end
