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
    entries_rule = entries.select{ |x| x.granule_class == 'RULE' }
    entries_proposed_rule = entries.select{ |x| x.granule_class == 'PRORULE' }
    entries_notice = entries.select{ |x| x.granule_class == 'NOTICE' }
    entries_presidential_document = entries.select{ |x| x.granule_class == 'PRESDOCU' }
    entries_unknown = entries.select{ |x| !['NOTICE', 'PRORULE', 'RULE', 'PRESDOCU'].include?(x.granule_class) }
    entries_correction = entries.select{ |x| x.document_number.start_with?('C1', 'C2', 'R1') }
    blank_pages = @issue.page_count -
                          @issue.entries_total_pages(entries_rule) -
                          @issue.entries_total_pages(entries_proposed_rule) -
                          @issue.entries_total_pages(entries_notice) -
                          @issue.entries_total_pages(entries_presidential_document) -
                          @issue.entries_total_pages(entries_unknown)
    blank_pages = blank_pages + 1 if @modsFile.end_page.to_i.odd?

    @issue.update(
      start_page: @modsFile.start_page,
      end_page: @modsFile.end_page,
      frontmatter_page_count: @modsFile.frontmatter_page_count,
      backmatter_page_count: @modsFile.backmatter_page_count,
      volume: @modsFile.volume,
      number: @modsFile.issue_number,
      rule_count: entries_rule.length,
      proposed_rule_count: entries_proposed_rule.length,
      notice_count: entries_notice.length,
      presidential_document_count: entries_presidential_document.length,
      unknown_document_count: entries_unknown.length,
      correction_count: entries_correction.length,
      rule_page_count: @issue.entries_total_pages(entries_rule),
      proposed_rule_page_count: @issue.entries_total_pages(entries_proposed_rule),
      notice_page_count: @issue.entries_total_pages(entries_notice),
      presidential_document_page_count: @issue.entries_total_pages(entries_presidential_document),
      unknown_document_page_count: @issue.entries_total_pages(entries_unknown),
      correction_page_count: @issue.entries_total_pages(entries_correction),
      blank_page_count: blank_pages
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
