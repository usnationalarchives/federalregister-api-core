class Content::EntryImporter::IssueUpdater
  def initialize(issue, modsFile, bulkdataFile)
    @issue = issue
    @modsFile = modsFile
    @bulkdataFile = bulkdataFile
  end

  def process
    update_issue
    create_issue_parts
  end

  private

  def update_issue
    @issue.update(
      frontmatter_page_count: @modsFile.frontmatter_page_count,
      backmatter_page_count: @modsFile.backmatter_page_count,
      volume: @modsFile.volume,
      number: @modsFile.issue_number
    )
  end

  def create_issue_parts
    nodes = @bulkdataFile.issue_part_nodes

    nodes.each do |n|
      IssuePart.create(issue_id: @issue.id, title: n[0], start_page: n[1], end_page: n[2])
    end
  end
end 
