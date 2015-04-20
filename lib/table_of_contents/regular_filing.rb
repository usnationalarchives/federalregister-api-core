class TableOfContents::RegularFiling < PublicInspectionTableOfContentsTransformer
  def toc
    @toc ||= TableOfContentsPresenter.new(
      issue.public_inspection_documents.regular_filing.scoped(:include => :docket_numbers),
      :always_include_parent_agencies => true
    )
  end

  private

  def json_path
    "#{json_toc_dir}/regular_filing.json"
  end
end
