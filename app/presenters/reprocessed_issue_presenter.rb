class ReprocessedIssuePresenter
  attr_reader :date

  LOADING_STATUSES = ["downloading_mods", "in_progress"]

  def initialize(date=Date.current)
    @date = date.is_a?(Date) ? date : Date.parse(date)
  end

  def issue
    @issue ||= Issue.find_by_publication_date(date)
  end

  def reprocessed_issues
    @reprocessed_issues ||=
      issue.
      reprocessed_issues.
      sort_by{|i|i.updated_at}.
      reverse
  end

  def show_reprocessing_buttons?
    reprocessed_issue_in_progress.present? && reprocessed_issue_in_progress.status == "pending_reprocess"
  end

  def display_loading_message?
    reprocessed_issue_in_progress.present? && LOADING_STATUSES.include?(reprocessed_issue_in_progress.status)
  end

  def most_recent_diff
    reprocessed_issues.first.diff
  end

  def most_recent_diff_processed?
    reprocessed_issues.first.status == "complete"
  end

  def reprocessed_issue_in_progress
    reprocessed_issues.to_a.find{|i|i.status != "complete"}
  end

  def reprocessed_issue_in_progress_status
    reprocessed_issue_in_progress.status if reprocessed_issue_in_progress
  end

  def reprocessed_issues_by_date
    @reprocessed_issues_by_date ||= ReprocessedIssue.
      all(:conditions=>"status = 'complete'").
      group_by(&:publication_date)
  end

  def reprocessed_issues_by_date_ordered
    reprocessed_issues_by_date.
    inject({}) do |hsh, (date, issues)|
      hsh[date] = issues.sort_by{|i|i.publication_date}.reverse
      hsh
    end
  end

end
