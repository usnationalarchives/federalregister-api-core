class Admin::ReprocessedIssuesController < AdminController
  layout 'admin_bootstrap'

  def index
    @presenter = ReprocessedIssuePresenter.new
  end

  def create
    begin
      date = Date.parse(params[:date])
      issue = Issue.find_by_publication_date(date)
      if issue
        reprocessed_issues_in_progress = issue.reprocessed_issues.
          to_a.find{|i| i.status == "pending_reprocess"}
        if reprocessed_issues_in_progress
          flash[:error] = "Reprocessing for #{date} is currently underway."
          redirect_to admin_reprocessed_issue_path(reprocessed_issues_in_progress.publication_date.to_s(:iso)) #Redirect to date-based reprocessed issue path
        else
          reprocessed_issue = ReprocessedIssue.create(
            :issue_id => issue.id,
            :user_id => current_user.id
          )
          reprocessed_issue.download_mods
          redirect_to admin_reprocessed_issue_path(reprocessed_issue.publication_date.to_s(:iso)) #Redirect to date-based reprocessed issue path
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
    date = Date.parse(params[:id])
    @presenter = ReprocessedIssuePresenter.new(date)
    if @presenter.reprocessed_issues.nil?
      flash[:error] = "No reprocessings exists for #{date}"
      redirect_to admin_reprocessed_issues_path
    end
  end

  def update
    reprocessed_issue = ReprocessedIssue.find_by_id(params[:id])
    reprocessed_issue.reprocess_issue
    redirect_to admin_reprocessed_issue_path(reprocessed_issue.publication_date.to_s(:iso))
  end

  def update_mods
    reprocessed_issue = ReprocessedIssue.find_by_id(params[:id])
    reprocessed_issue.download_mods
    redirect_to admin_reprocessed_issue_path(reprocessed_issue.publication_date.to_s(:iso))
  end

end
