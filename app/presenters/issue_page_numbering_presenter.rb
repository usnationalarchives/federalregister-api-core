class IssuePageNumberingPresenter
  extend Memoist

  attr_reader :current_issue

  def initialize(date)
    @current_issue = Issue.find_by_publication_date!(date)
  end

  def previous_issue
    current_issue.previous
  end

  def previous_issue_end_page
    previous_issue.entries.maximum(:end_page)
  end
  memoize :previous_issue_end_page

  def current_issue_start_page
    current_issue.entries.minimum(:start_page)
  end
  memoize :current_issue_start_page

  def status_message
    if page_numbering_correct?
      'Page numbers are sequential'
    else
      'Page numbers are non-sequential and may be misnumbered'
    end
  end

  def page_numbering_correct?
    (previous_issue_end_page + 1) == current_issue_start_page
  end

end
