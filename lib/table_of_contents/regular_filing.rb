class TableOfContents::RegularFiling < TableOfContentsTransformer
  def self.perform(date)
    new(date).save(table_of_contents)
  end

  def table_of_contents
    agency_hash(agencies, entries_without_agencies)
  end

  def issue
    @issue ||= PublicInspectionIssue.published.find_by_publication_date!(date)
  end

  def toc
    @toc ||= TableOfContentsPresenter.new(
      issue.public_inspection_documents.regular_filing.scoped(:include => :docket_numbers),
      :always_include_parent_agencies => true
    )
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

  def json_path
    "#{json_toc_dir}/regular_filing.json"
  end
end
