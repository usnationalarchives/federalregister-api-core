class Content::EntryImporter::IssueUpdater
  def initialize(issue, modsFile)
    @issue = issue
    @modsFile = modsFile
  end

  def process
    @issue.update(
      frontmatter_page_count: @modsFile.document_numbers.first.split("-")[1],
      backmatter_page_count: @modsFile.document_numbers.last.split("-")[1],
      volume: @modsFile.volume,
      number: @modsFile.issue_number
    )
  end
end 
