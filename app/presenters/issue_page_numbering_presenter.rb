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
    if previous_issue_end_page.odd?
      page_gap = 2
    else
      page_gap = 1
    end

    ((previous_issue_end_page + page_gap) == current_issue_start_page) 
  end

end
