class Content::EntryImporter::IssueUpdater
  extend Memoist
  KNOWN_DOCUMENT_TYPES = %w(NOTICE PRESDOCU PRORULE RULE)
  CORRECTION_PREFIXES = %w(C1 C2 R1)

  def initialize(issue, modsFile, bulkdataFile)
    @issue = issue
    @modsFile = modsFile
    @bulkdataFile = bulkdataFile
  end

  def process
    delete_issue_parts
    if create_issue_parts?
      create_issue_parts
    end
    update_issue
  end

  private

  attr_reader :issue

  BULK_DATA_AVAILABILITY_STARTS_ON = Date.new(2000,1,1)
  def create_issue_parts?
    issue.publication_date > BULK_DATA_AVAILABILITY_STARTS_ON
  end

  def update_issue
    @issue.reload

    @issue.update(
      start_page: issue_start_page,
      end_page: issue_end_page,
      frontmatter_page_count: @modsFile.frontmatter_page_count,
      backmatter_page_count: @modsFile.backmatter_page_count,
      volume: @modsFile.volume,
      number: @modsFile.issue_number,
      rule_count: entries_of_type("RULE").count,
      proposed_rule_count: entries_of_type("PRORULE").count,
      notice_count: entries_of_type("NOTICE").count,
      presidential_document_count: entries_of_type("PRESDOCU").count,
      unknown_document_count: entries_of_type("UNKNOWN").count,
      correction_count: entries_of_type("CORRECTION").count,
      rule_page_count: pages_of_document_type("RULE").count,
      proposed_rule_page_count: pages_of_document_type("PRORULE").count,
      notice_page_count: pages_of_document_type("NOTICE").count,
      presidential_document_page_count: pages_of_document_type("PRESDOCU").count,
      unknown_document_page_count: pages_of_document_type("UNKNOWN").count, 
      correction_page_count: pages_of_document_type("CORRECTION").count,
      blank_page_count: blank_pages.count
    )
  end

  def entries
    @issue.entries
  end

  def entries_of_type(document_type)
    if KNOWN_DOCUMENT_TYPES.include?(document_type)
      entries.select{|x| x.granule_class == document_type}
    elsif document_type == "UNKNOWN"
      entries.reject{|x| KNOWN_DOCUMENT_TYPES.include?(x.granule_class) }
    elsif document_type == "CORRECTION"
      entries.select{ |x| x.document_number.start_with?(*CORRECTION_PREFIXES) }
    else
      raise "Unknown requested document type: #{document_type}"
    end
  end
  memoize :entries_of_type

  def pages_of_document_type(document_type)
    prior_entry = nil
    pages = entries_of_type(document_type).flat_map do |entry|
      (entry.start_page..entry.end_page).to_a
    end

    if document_type == "PRESDOCU"
      entries_of_type(document_type).each do |entry|
        # presdocs include the blank page after them, unless it is the one
        if entry.end_page.odd? && pages.include?(entry.end_page+2)
          pages << entry.end_page + 1
        end
      end

      # add the special part title pages to the page counts for the document type
      if document_type == 'PRESDOCU'
        pages += @issue.issue_parts.select{|x| x.initial_document_type == document_type}.map(&:start_page)
      end
    end

    pages.uniq
  end
  memoize :pages_of_document_type

  def blank_pages
    (issue_start_page..issue_end_page).to_a -
      (KNOWN_DOCUMENT_TYPES+["UNKNOWN"]).flat_map{|x| pages_of_document_type(x) }
  end

  def issue_start_page
    @modsFile.start_page.to_i
  end

  def issue_end_page
    [@modsFile.end_page.to_i, (@issue.entries.last&.end_page || 0), (@issue.issue_parts.last&.end_page || 0)].max
  end
  memoize :issue_end_page

  def create_issue_parts
    @bulkdataFile.issue_part_nodes.each do |title, start_page, end_page|
      scope = @issue.entries.where("start_page >= ? AND end_page <= ?", start_page, end_page)
      entry = scope.order(:start_page => "asc").first
      issue_part = IssuePart.create(
        issue_id: @issue.id,
        title: title,
        start_page: start_page,
        end_page: end_page,
        initial_document_type: granule_class(entry)
      )
      scope.update_all(issue_part_id: issue_part.id)
    end
  end

  def granule_class(entry)
    if entry.present? && KNOWN_DOCUMENT_TYPES.include?(entry.granule_class)
      entry.granule_class
    elsif entry.blank? || (entry.present? && !KNOWN_DOCUMENT_TYPES.include?(entry.granule_class))
      "UNKNOWN"
    end
  end

  def delete_issue_parts
    @issue.issue_parts.delete_all # delete records so that they will be recreated if mods file got updated
  end
end 
