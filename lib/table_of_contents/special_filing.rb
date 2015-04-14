class TableOfContents::SpecialFiling < TableOfContentsTransformer

  def initialize(date)
    super
  end

  def self.perform(date)
    toc_stub = new(date).save_public_inspection_special_filings_toc
  end

  def issue
    @issue ||= PublicInspectionIssue.published.find_by_publication_date!(date)
  end

  def special_documents
    @special_documents ||= TableOfContentsPresenter.new(
      issue.public_inspection_documents.special_filing.scoped(:include => :docket_numbers),
      :always_include_parent_agencies => true
    )
  end

  def agencies_special_filings
    special_documents.agencies
  end

  def entries_without_agencies_special_filings
    special_documents.entries_without_agencies
  end

  def special_filings_toc
    agency_hash(agencies_special_filings, entries_without_agencies_special_filings)
  end

  def save_public_inspection_special_filings_toc
    save_file(public_inspection_output_path, "special_filing.json", special_filings_toc.to_json)
  end

private

  def public_inspection_output_path
    path = "data/public_inspection_issues/json/#{date.to_s(:year_month)}/#{date.strftime('%d')}/"
  end


end