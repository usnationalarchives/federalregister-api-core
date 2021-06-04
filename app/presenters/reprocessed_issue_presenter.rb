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
    @reprocessed_issues ||= issue.
      reprocessed_issues.
      sort_by(&:updated_at).
      reverse
  end

  def show_reprocessing_buttons?
    reprocessed_issue_in_progress_status == "pending_reprocess"
  end

  def display_loading_message?
    reprocessed_issue_in_progress.present? &&
      LOADING_STATUSES.include?(reprocessed_issue_in_progress.status)
  end

  def most_recent_reprocessed_issue
    reprocessed_issues.first
  end

  def most_recent_diff
    most_recent_reprocessed_issue.diff
  end

  def most_recent_html_diff
    most_recent_reprocessed_issue.html_diff.try(:html_safe)
  end

  def most_recent_no_mods_changes_message
    "No MODS changes identified as of #{most_recent_reprocessed_issue.updated_at.to_s(:short_date_then_time)}"
  end

  def most_recent_diff_processed?
    most_recent_reprocessed_issue.status == "complete"
  end

  def reprocessed_issue_in_progress
    reprocessed_issues.to_a.find{|i| i.status != "complete"}
  end

  def reprocessed_issue_in_progress_status
    reprocessed_issue_in_progress.status if reprocessed_issue_in_progress
  end

  def reprocessed_issues_by_date
    @reprocessed_issues_by_date ||= ReprocessedIssue.
      where("status = 'complete' || status = 'failed'").
      joins(:issue).
      order("reprocessed_issues.created_at DESC").
      limit(10)
  end
end
