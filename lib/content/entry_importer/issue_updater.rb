class Content::EntryImporter::IssueUpdater
  def initialize(issue, modsFile, bulkdataFile)
    @issue = issue
    @modsFile = modsFile
    @bulkdataFile = bulkdataFile
  end

  def process
    update_issue
    delete_issue_parts
    create_issue_parts
  end

  private

  def update_issue
    entries = @issue.entries
    @issue.update(
      frontmatter_page_count: @modsFile.frontmatter_page_count,
      backmatter_page_count: @modsFile.backmatter_page_count,
      volume: @modsFile.volume,
      number: @modsFile.issue_number,
      rule_count: entries.of_type('RULE').count,
      proposed_rule_count: entries.of_type('PRORULE').count,
      notice_count: entries.of_type('NOTICE').count,
      presidential_document_count: entries.of_type('PRESDOCU').count,
      unknown_document_count: entries.where.not(granule_class: ['NOTICE', 'PRORULE', 'RULE', 'PRESDOCU']).count
    )
  end

  def create_issue_parts
    nodes = @bulkdataFile.issue_part_nodes

    nodes.each do |n|
      entry = @issue.entries.where("start_page >= ? AND end_page <= ?", n[1], n[2]).order(:start_page => "asc").first
      issue_part = IssuePart.where(issue_id: @issue.id, title: n[0], start_page: n[1], end_page: n[2], initial_document_type: granule_class(entry)).first_or_create
      @issue.entries.where("start_page >= ? AND end_page <= ?", issue_part.start_page, issue_part.end_page).update_all(issue_part_id: issue_part.id)
    end
  end

  def granule_class(entry)
    allowed_granule_classes = ['NOTICE', 'PRESDOCU', 'PRORULE', 'RULE']

    if entry.present? && allowed_granule_classes.include?(entry.granule_class)
      entry.granule_class
    elsif entry.blank? || (entry.present? && !allowed_granule_classes.include?(entry.granule_class))
      "UNKNOWN"
    end
  end

  def delete_issue_parts
    IssuePart.where(issue_id: @issue.id).delete_all # delete records so that they will be recreated if mods file got updated
  end
end 
