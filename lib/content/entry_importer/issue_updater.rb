class Content::EntryImporter::IssueUpdater
  def initialize(issue, modsFile)
    @issue = issue
    @modsFile = modsFile
  end

  def process
    @issue.update(
      frontmatter_page_count: @modsFile.frontmatter_page_count,
      backmatter_page_count: @modsFile.backmatter_page_count,
      volume: @modsFile.volume,
      number: @modsFile.issue_number
    )
  end
end 
