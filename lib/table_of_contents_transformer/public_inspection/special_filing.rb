class TableOfContentsTransformer::PublicInspection::SpecialFiling < TableOfContentsTransformer::PublicInspection
  def toc_presenter
    @toc_presenter ||= TableOfContentsPresenter.new(
      issue.
        public_inspection_documents.
        special_filing.
        scoped(:include => :docket_numbers),
      :always_include_parent_agencies => true
    )
  end

  def self.toc_file_exists?(date)
    path_manager = FileSystemPathManager.new(date)
    File.exists?(path_manager.public_inspection_issue_special_filing_json_toc_path)
  end

  private

  def json_path
    path_manager.public_inspection_issue_special_filing_json_toc_path
  end
end
