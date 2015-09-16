class Admin::ReprocessedIssuesController < AdminController

  def index
  end

  def create
    begin
      date = Date.parse(params[:date])
      issue = Issue.find_by_publication_date(date)
      if issue
        reprocessed_issues_in_progress = issue.reprocessed_issues.to_a.find{|i|i.status != "complete"}
        if reprocessed_issues_in_progress
          redirect_to admin_reprocessed_issue_path(reprocessed_issues_in_progress)
        else
          reprocessed_issue = ReprocessedIssue.create(:issue_id => issue.id)
          reprocessed_issue.download_mods
          redirect_to admin_reprocessed_issue_path(reprocessed_issue)
        end
      else
        flash[:error] = "An FR issue does not exist for the date provided."
        redirect_to admin_reprocessed_issues_path
      end

    rescue ArgumentError
      flash[:error] = "Please provide a valid date"
      redirect_to admin_reprocessed_issues_path
    end
  end

  def show
    @reprocessed_issue = ReprocessedIssue.find_by_id(params[:id])
    if @reprocessed_issue.status == "complete"
      flash[:notice] = "Success!"
      redirect_to admin_reprocessed_issues_path
    elsif @reprocessed_issue.status == "pending_reprocess"
    end
  end

  def update
    reprocessed_issue = ReprocessedIssue.find_by_id(params[:id])
    reprocessed_issue.reprocess_issue
    redirect_to admin_reprocessed_issue_path(reprocessed_issue)
  end

  def update_mods
    reprocessed_issue = ReprocessedIssue.find_by_id(params[:id])
    reprocessed_issue.download_mods
    redirect_to admin_reprocessed_issue_path(reprocessed_issue)
  end

end
