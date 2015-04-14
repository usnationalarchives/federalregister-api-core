class TableOfContents::RegularFiling < TableOfContentsTransformer

  def initialize(date)
    super
  end

  def self.perform(date)
    new(date).save_public_inspection_regular_filings_toc
  end

  def issue
    @issue ||= PublicInspectionIssue.published.find_by_publication_date!(date)
  end

  def regular_documents
    @regular_documents ||= TableOfContentsPresenter.new(
      issue.public_inspection_documents.regular_filing.scoped(:include => :docket_numbers),
      :always_include_parent_agencies => true
    )
  end

  def agencies_regular_filings
    regular_documents.agencies
  end

  def entries_without_agencies_regular_filings
    regular_documents.entries_without_agencies
  end

  def regular_filings_toc
    initialize_public_inspection_toc
    agency_hash(agencies_regular_filings, entries_without_agencies_regular_filings)
  end

  def save_public_inspection_regular_filings_toc
    save_file(public_inspection_output_path, "regular_filing.json", regular_filings_toc.to_json)
  end


  def regular_filings_toc
    agency_hash(agencies_regular_filings, entries_without_agencies_regular_filings)
  end

private

  def public_inspection_output_path
    path = "data/public_inspection_issues/json/#{date.to_s(:year_month)}/#{date.strftime('%d')}/"
  end


end