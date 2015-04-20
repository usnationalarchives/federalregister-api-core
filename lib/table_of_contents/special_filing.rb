class TableOfContents::SpecialFiling < PublicInspectionTableOfContentsTransformer
  def toc
    @toc ||= TableOfContentsPresenter.new(
      issue.public_inspection_documents.special_filing.scoped(:include => :docket_numbers),
      :always_include_parent_agencies => true
    )
  end

  private

  def json_path
    "#{json_toc_dir}/special_filing.json"
  end
end
